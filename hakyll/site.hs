--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import Control.Monad as M
import           Data.Monoid (mappend)
import qualified Data.List.Split as SP
import qualified Data.Map as Map
import qualified Data.Set as Set
import           Hakyll
import Text.Pandoc (
  WriterOptions(writerHTMLMathMethod)
  , HTMLMathMethod(MathJax)
  )
import qualified Text.Pandoc.Options as PD

--------------------------------------------------------------------------------

main :: IO ()
main = do
  hakyllWith config $ do
    match "images/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "reveal.js/**" $ do
        route   idRoute
        compile copyFileCompiler

    match (fromList ["about.markdown", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" (mathCtx `mappend` defaultContext)
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompilerWith defaultHakyllReaderOptions pandocOptions
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/post-page.html" postCtx
            >>= loadAndApplyTemplate "templates/default.html" (mathCtx `mappend` postCtx)
            >>= relativizeUrls

    ids <- do
      ids' <- getMatches "posts/*"
      sortRecentFirst ids'
    let pages = SP.chunksOf 50 ids
        lastPage = length pages
        pagePath i = "archive" ++ show i ++ ".html"

    M.forM_ (zip [1..] pages) $ \(i, ids) -> do
        create [fromFilePath (pagePath i)] $ do
            route idRoute
            compile $ do
                posts <- sequence (map load ids)
                let archiveCtx =
                        listField "posts" postCtx (return posts) `mappend`
                        constField "title" ("Archives " ++ show i) `mappend`
                        (if i > 1 then constField "prevPage" (pagePath (i - 1))
                                  else mempty) `mappend`
                        (if i < lastPage then constField "nextPage" (pagePath (i + 1))
                                         else mempty) `mappend`
                        defaultContext

                makeItem ""
                    >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                    >>= loadAndApplyTemplate "templates/default.html" (mathCtx `mappend` archiveCtx)
                    >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- fmap (take 5) . recentFirst =<<
                     loadAllSnapshots "posts/*" "content"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Top"                 `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" (forceMathCtx `mappend` indexCtx)
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler

    match "presentations/*" $ do
      let w = defaultHakyllWriterOptions {
            PD.writerSlideVariant = PD.RevealJsSlides
            , PD.writerHTMLMathMethod = MathJax undefined
            , PD.writerHtml5 = True
            -- , PD.writerIncremental = True
            }
      let r = let r' = defaultHakyllReaderOptions in r' {
            PD.readerExtensions = Set.filter (/= PD.Ext_auto_identifiers) (PD.readerExtensions r')
            }
      route $ setExtension "html"
      compile $ do
        item <- pandocCompilerWith r w
        item <- loadAndApplyTemplate "templates/presentation.html" postCtx item
        return item

--------------------------------------------------------------------------------
pandocOptions :: WriterOptions
pandocOptions = defaultHakyllWriterOptions{ writerHTMLMathMethod = MathJax "" }

config :: Configuration
config = defaultConfiguration { deployCommand = deploy }
  where deploy = "cp -R _site/* ../ && stack exec -- site clean"

postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

mathTag :: String
mathTag = "<script type=\"text/javascript\" src=\"http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML\"></script>"

mathCtx :: Context a
mathCtx = field "mathjax" $ \item -> do
  metadata <- getMetadata $ itemIdentifier item
  return $ if "mathjax" `Map.member` metadata
           then mathTag
           else ""

forceMathCtx :: Context a
forceMathCtx = field "mathjax" $ (const . return) mathTag
