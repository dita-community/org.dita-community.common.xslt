<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="http://www.example.com/functions/local"
  exclude-result-prefixes="xs local"
  version="2.0">
  <xsl:import href="../xsl/relpath_util.xsl"/>
  <xsl:import href="../xsl/dita-support-lib.xsl"/>
  <xsl:import href="../xsl/calculate_map_bos.xsl"/>
  <!-- Test harness to exercise the calculate-map-bos() function.
    
       Apply it to any DITA map.
       
       The result is an XML BOS report.
       
    -->
  
  <xsl:output
    indent="yes"
  />
  <xsl:template match="/">
    <bos-report>
      <xsl:sequence select="local:calculateBOS(., true())"/>
    </bos-report>
  </xsl:template>
</xsl:stylesheet>