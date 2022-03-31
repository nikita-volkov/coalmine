-- |
-- Plotting lib.
module Coalmine.Plotting
  ( renderTimeSeriesDiagramToSvgFile,
    renderPairedTimeSeriesDiagramToSvgFile,

    -- * Types
    module Coalmine.Plotting.Types,
  )
where

import Coalmine.Plotting.Types
import Coalmine.Prelude
import qualified Coalmine.VectorExtras.Generic as GVec
import Control.Lens
import qualified Data.Colour.Names as ColourNames
import qualified Data.Vector.Unboxed as UVec
import qualified Graphics.Rendering.Chart.Backend.Cairo as Chart
import qualified Graphics.Rendering.Chart.Easy as Chart

renderTimeSeriesDiagramToSvgFile :: FilePath -> TimeSeriesDiagram -> IO ()
renderTimeSeriesDiagramToSvgFile path values =
  void $ Chart.renderableToFile options (toString path) (compileTimeSeriesDiagramRenderable values)
  where
    options =
      def
        & Chart.fo_format .~ Chart.SVG

renderPairedTimeSeriesDiagramToSvgFile :: FilePath -> PairedTimeSeriesDiagram -> IO ()
renderPairedTimeSeriesDiagramToSvgFile path values =
  void $ Chart.renderableToFile options (toString path) (compilePairedTimeSeriesDiagramRenderable values)
  where
    options =
      def
        & Chart.fo_format .~ Chart.SVG

-- *

compileTimeSeriesDiagramRenderable :: TimeSeriesDiagram -> Chart.Renderable ()
compileTimeSeriesDiagramRenderable cfg =
  Chart.toRenderable (compileLayout cfg)

compilePairedTimeSeriesDiagramRenderable :: PairedTimeSeriesDiagram -> Chart.Renderable ()
compilePairedTimeSeriesDiagramRenderable cfg =
  Chart.toRenderable (compileLayoutLR cfg)

compileLayoutLR :: PairedTimeSeriesDiagram -> Chart.LayoutLR UTCTime Double Double
compileLayoutLR cfg =
  def
    & Chart.layoutlr_title .~ toString (#title cfg)
    & Chart.layoutlr_left_axis . Chart.laxis_override .~ Chart.axisGridHide
    & Chart.layoutlr_right_axis . Chart.laxis_override .~ Chart.axisGridHide
    & Chart.layoutlr_x_axis . Chart.laxis_override .~ Chart.axisGridHide
    & Chart.layoutlr_plots .~ plots
  where
    plots =
      fmap Left left <> fmap Right right
      where
        left =
          compilePlots (#startTime cfg) (realToFrac (#sampleInterval cfg)) (#leftCharts cfg)
        right =
          compilePlots (#startTime cfg) (realToFrac (#sampleInterval cfg)) (#rightCharts cfg)

compileLayout :: TimeSeriesDiagram -> Chart.Layout UTCTime Double
compileLayout cfg =
  def
    & Chart.layout_title .~ toString (#title cfg)
    & Chart.layout_y_axis . Chart.laxis_override .~ Chart.axisGridHide
    & Chart.layout_plots .~ compilePlots (#startTime cfg) (realToFrac (#sampleInterval cfg)) (#charts cfg)

compilePlots :: UTCTime -> NominalDiffTime -> BVec Chart -> [Chart.Plot UTCTime Double]
compilePlots startTime interval =
  GVec.mapToList (Chart.toPlot . compilePlotLines startTime interval)

compilePlotLines :: UTCTime -> NominalDiffTime -> Chart -> Chart.PlotLines UTCTime Double
compilePlotLines startTime interval cfg =
  def
    & Chart.plot_lines_title .~ toString (#title cfg)
    & Chart.plot_lines_style . Chart.line_color .~ compileAlphaColour (#alpha cfg) (#color cfg)
    & Chart.plot_lines_style . Chart.line_width .~ #weight cfg
    & Chart.plot_lines_values .~ [compileTimeSeriesValues startTime interval (#data cfg)]

compileTimeSeriesValues :: UTCTime -> NominalDiffTime -> UVec Double -> [(UTCTime, Double)]
compileTimeSeriesValues startTime diff vec =
  UVec.foldr (\y next x -> (x, y) : next (addUTCTime diff x)) (const []) vec startTime

compileAlphaColour :: Double -> Colour -> Chart.AlphaColour Double
compileAlphaColour alpha color =
  Chart.withOpacity (compileColour color) alpha

compileColour :: (Ord a, Floating a) => Colour -> Chart.Colour a
compileColour = \case
  AliceblueColour -> ColourNames.aliceblue
  AntiquewhiteColour -> ColourNames.antiquewhite
  AquaColour -> ColourNames.aqua
  AquamarineColour -> ColourNames.aquamarine
  AzureColour -> ColourNames.azure
  BeigeColour -> ColourNames.beige
  BisqueColour -> ColourNames.bisque
  BlackColour -> ColourNames.black
  BlanchedalmondColour -> ColourNames.blanchedalmond
  BlueColour -> ColourNames.blue
  BluevioletColour -> ColourNames.blueviolet
  BrownColour -> ColourNames.brown
  BurlywoodColour -> ColourNames.burlywood
  CadetblueColour -> ColourNames.cadetblue
  ChartreuseColour -> ColourNames.chartreuse
  ChocolateColour -> ColourNames.chocolate
  CoralColour -> ColourNames.coral
  CornflowerblueColour -> ColourNames.cornflowerblue
  CornsilkColour -> ColourNames.cornsilk
  CrimsonColour -> ColourNames.crimson
  CyanColour -> ColourNames.cyan
  DarkblueColour -> ColourNames.darkblue
  DarkcyanColour -> ColourNames.darkcyan
  DarkgoldenrodColour -> ColourNames.darkgoldenrod
  DarkgrayColour -> ColourNames.darkgray
  DarkgreenColour -> ColourNames.darkgreen
  DarkgreyColour -> ColourNames.darkgrey
  DarkkhakiColour -> ColourNames.darkkhaki
  DarkmagentaColour -> ColourNames.darkmagenta
  DarkolivegreenColour -> ColourNames.darkolivegreen
  DarkorangeColour -> ColourNames.darkorange
  DarkorchidColour -> ColourNames.darkorchid
  DarkredColour -> ColourNames.darkred
  DarksalmonColour -> ColourNames.darksalmon
  DarkseagreenColour -> ColourNames.darkseagreen
  DarkslateblueColour -> ColourNames.darkslateblue
  DarkslategrayColour -> ColourNames.darkslategray
  DarkslategreyColour -> ColourNames.darkslategrey
  DarkturquoiseColour -> ColourNames.darkturquoise
  DarkvioletColour -> ColourNames.darkviolet
  DeeppinkColour -> ColourNames.deeppink
  DeepskyblueColour -> ColourNames.deepskyblue
  DimgrayColour -> ColourNames.dimgray
  DimgreyColour -> ColourNames.dimgrey
  DodgerblueColour -> ColourNames.dodgerblue
  FirebrickColour -> ColourNames.firebrick
  FloralwhiteColour -> ColourNames.floralwhite
  ForestgreenColour -> ColourNames.forestgreen
  FuchsiaColour -> ColourNames.fuchsia
  GainsboroColour -> ColourNames.gainsboro
  GhostwhiteColour -> ColourNames.ghostwhite
  GoldColour -> ColourNames.gold
  GoldenrodColour -> ColourNames.goldenrod
  GrayColour -> ColourNames.gray
  GreenColour -> ColourNames.green
  GreenyellowColour -> ColourNames.greenyellow
  GreyColour -> ColourNames.grey
  HoneydewColour -> ColourNames.honeydew
  HotpinkColour -> ColourNames.hotpink
  IndianredColour -> ColourNames.indianred
  IndigoColour -> ColourNames.indigo
  IvoryColour -> ColourNames.ivory
  KhakiColour -> ColourNames.khaki
  LavenderColour -> ColourNames.lavender
  LavenderblushColour -> ColourNames.lavenderblush
  LawngreenColour -> ColourNames.lawngreen
  LemonchiffonColour -> ColourNames.lemonchiffon
  LightblueColour -> ColourNames.lightblue
  LightcoralColour -> ColourNames.lightcoral
  LightcyanColour -> ColourNames.lightcyan
  LightgoldenrodyellowColour -> ColourNames.lightgoldenrodyellow
  LightgrayColour -> ColourNames.lightgray
  LightgreenColour -> ColourNames.lightgreen
  LightgreyColour -> ColourNames.lightgrey
  LightpinkColour -> ColourNames.lightpink
  LightsalmonColour -> ColourNames.lightsalmon
  LightseagreenColour -> ColourNames.lightseagreen
  LightskyblueColour -> ColourNames.lightskyblue
  LightslategrayColour -> ColourNames.lightslategray
  LightslategreyColour -> ColourNames.lightslategrey
  LightsteelblueColour -> ColourNames.lightsteelblue
  LightyellowColour -> ColourNames.lightyellow
  LimeColour -> ColourNames.lime
  LimegreenColour -> ColourNames.limegreen
  LinenColour -> ColourNames.linen
  MagentaColour -> ColourNames.magenta
  MaroonColour -> ColourNames.maroon
  MediumaquamarineColour -> ColourNames.mediumaquamarine
  MediumblueColour -> ColourNames.mediumblue
  MediumorchidColour -> ColourNames.mediumorchid
  MediumpurpleColour -> ColourNames.mediumpurple
  MediumseagreenColour -> ColourNames.mediumseagreen
  MediumslateblueColour -> ColourNames.mediumslateblue
  MediumspringgreenColour -> ColourNames.mediumspringgreen
  MediumturquoiseColour -> ColourNames.mediumturquoise
  MediumvioletredColour -> ColourNames.mediumvioletred
  MidnightblueColour -> ColourNames.midnightblue
  MintcreamColour -> ColourNames.mintcream
  MistyroseColour -> ColourNames.mistyrose
  MoccasinColour -> ColourNames.moccasin
  NavajowhiteColour -> ColourNames.navajowhite
  NavyColour -> ColourNames.navy
  OldlaceColour -> ColourNames.oldlace
  OliveColour -> ColourNames.olive
  OlivedrabColour -> ColourNames.olivedrab
  OrangeColour -> ColourNames.orange
  OrangeredColour -> ColourNames.orangered
  OrchidColour -> ColourNames.orchid
  PalegoldenrodColour -> ColourNames.palegoldenrod
  PalegreenColour -> ColourNames.palegreen
  PaleturquoiseColour -> ColourNames.paleturquoise
  PalevioletredColour -> ColourNames.palevioletred
  PapayawhipColour -> ColourNames.papayawhip
  PeachpuffColour -> ColourNames.peachpuff
  PeruColour -> ColourNames.peru
  PinkColour -> ColourNames.pink
  PlumColour -> ColourNames.plum
  PowderblueColour -> ColourNames.powderblue
  PurpleColour -> ColourNames.purple
  RedColour -> ColourNames.red
  RosybrownColour -> ColourNames.rosybrown
  RoyalblueColour -> ColourNames.royalblue
  SaddlebrownColour -> ColourNames.saddlebrown
  SalmonColour -> ColourNames.salmon
  SandybrownColour -> ColourNames.sandybrown
  SeagreenColour -> ColourNames.seagreen
  SeashellColour -> ColourNames.seashell
  SiennaColour -> ColourNames.sienna
  SilverColour -> ColourNames.silver
  SkyblueColour -> ColourNames.skyblue
  SlateblueColour -> ColourNames.slateblue
  SlategrayColour -> ColourNames.slategray
  SlategreyColour -> ColourNames.slategrey
  SnowColour -> ColourNames.snow
  SpringgreenColour -> ColourNames.springgreen
  SteelblueColour -> ColourNames.steelblue
  TanColour -> ColourNames.tan
  TealColour -> ColourNames.teal
  ThistleColour -> ColourNames.thistle
  TomatoColour -> ColourNames.tomato
  TurquoiseColour -> ColourNames.turquoise
  VioletColour -> ColourNames.violet
  WheatColour -> ColourNames.wheat
  WhiteColour -> ColourNames.white
  WhitesmokeColour -> ColourNames.whitesmoke
  YellowColour -> ColourNames.yellow
  YellowgreenColour -> ColourNames.yellowgreen