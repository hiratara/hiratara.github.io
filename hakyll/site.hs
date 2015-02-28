--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
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
    match "images/*" $ do
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

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
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
            , PD.writerIncremental = True
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
  where deploy = "cp -R _site/* ../ && ./site clean"

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
