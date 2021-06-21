<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis hasScaleBasedVisibilityFlag="0" version="3.8.2-Zanzibar" minScale="1e+08" maxScale="0" styleCategories="AllStyleCategories">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
  </flags>
  <customproperties>
    <property value="false" key="WMSBackgroundLayer"/>
    <property value="false" key="WMSPublishDataSourceUrl"/>
    <property value="0" key="embeddedWidgets/count"/>
    <property value="Value" key="identify/format"/>
  </customproperties>
  <pipe>
    <rasterrenderer type="paletted" band="1" opacity="1" alphaBand="-1">
      <rasterTransparency/>
      <minMaxOrigin>
        <limits>None</limits>
        <extent>WholeRaster</extent>
        <statAccuracy>Estimated</statAccuracy>
        <cumulativeCutLower>0.02</cumulativeCutLower>
        <cumulativeCutUpper>0.98</cumulativeCutUpper>
        <stdDevFactor>2</stdDevFactor>
      </minMaxOrigin>
      <colorPalette>
        <paletteEntry color="#44aece" alpha="255" value="1" label="1"/>
        <paletteEntry color="#085801" alpha="255" value="2" label="2"/>
        <paletteEntry color="#000000" alpha="255" value="3" label="3"/>
        <paletteEntry color="#de0013" alpha="255" value="4" label="4"/>
        <paletteEntry color="#601e1d" alpha="255" value="6" label="6"/>
        <paletteEntry color="#670704" alpha="255" value="7" label="7"/>
        <paletteEntry color="#a47158" alpha="255" value="8" label="8"/>
        <paletteEntry color="#ced33e" alpha="255" value="9" label="9"/>
        <paletteEntry color="#31db67" alpha="255" value="10" label="10"/>
        <paletteEntry color="#fffc17" alpha="255" value="11" label="11"/>
        <paletteEntry color="#93dd38" alpha="255" value="12" label="12"/>
        <paletteEntry color="#32b23b" alpha="255" value="13" label="13"/>
        <paletteEntry color="#cea15d" alpha="255" value="18" label="18"/>
      </colorPalette>
      <colorramp type="randomcolors" name="[source]"/>
    </rasterrenderer>
    <brightnesscontrast brightness="0" contrast="0"/>
    <huesaturation colorizeRed="255" colorizeBlue="128" grayscaleMode="0" colorizeGreen="128" saturation="0" colorizeOn="0" colorizeStrength="100"/>
    <rasterresampler maxOversampling="2"/>
  </pipe>
  <blendMode>0</blendMode>
</qgis>
