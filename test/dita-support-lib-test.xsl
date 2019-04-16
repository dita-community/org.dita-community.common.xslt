<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:df="http://dita2indesign.org/dita/functions"
  exclude-result-prefixes="xs xd df"
  version="3.0"
  expand-text="yes"
  >
  
  <!-- Simple smoke test for the dita-support-lib.xsl.
   
    -->
  
  <xsl:import href="../xsl/relpath_util.xsl"/>
  <xsl:import href="../xsl/dita-support-lib.xsl"/>
  
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:template name="run-all-tests" match="/">
    <xsl:variable name="test-data" as="node()*">
      <foo id="topicid" class="- topic/topic foo/foo ">
        <title class="- topic/title">The Topic Title</title>
        <body class="- topic/body ">
          <p class="- topic/p ">This is a paragraph this is <ph class="- topic/ph ">This is a phrase</ph>.</p>
        </body>
      </foo>
    </xsl:variable>
    <xsl:variable name="tests" as="node()">
      <testcase name="df:class tests">
        <test name="df:class 1" pass="{df:class($test-data, 'foo/foo')}"/>
        <test name="df:class 2" pass="{df:class($test-data/title, 'topic/title')}"/>
        <test name="df:class 3" pass="{df:class($test-data/title, 'topic/title ')}"/>
        <test name="df:isBlock 1" pass="{df:isBlock(($test-data//p)[1])}" />
        <test name="df:isBlock 2" pass="{not(df:isBlock(($test-data//p/ph)[1]))}" />
        <test name="df:isInline 1" pass="{df:isInline(($test-data//p/ph)[1])}" />
        <test name="df:isInline 2" pass="{not(df:isInline(($test-data//p)[1]))}" />
        <test name="df:hasBlockChildren 1" pass="{df:hasBlockChildren($test-data/body)}" />
        <test name="df:hasBlockChildren 2" pass="{not(df:hasBlockChildren($test-data/body/p[1]))}" />
      </testcase>
    </xsl:variable>
    
    <test-results>
      <xsl:if test="$tests/test[@pass = 'false']">
        <failures>
          <xsl:apply-templates select="$tests"/>
        </failures>
      </xsl:if>
      <xsl:sequence select="$tests"/>
    </test-results>
    
  </xsl:template>
  
  <xsl:template match="testcase">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="test[@pass = 'false']">
    <fail name="{@name}"/>
  </xsl:template>
  
</xsl:stylesheet>