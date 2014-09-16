<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ts="http://tagsmiths.com/dita/functions"
   exclude-result-prefixes="xs ts">

   <!-- Unit tests for the dita_tidy_utils.xsl function library 
  
       To run this either give it any XML document (such as this XSLT document)
       as input or specify the template "run-all-tests" as the initial
       template to run.
       
       The test results are written to the primary result document.
  
  -->
   <xsl:include href="../xsl/dita_tidy_utils.xsl"/>
   <xsl:output method="xml" indent="yes"/>


   <xsl:template match="/" name="run-all-tests">
      <xsl:variable name="test-data" as="element()">
         <test_data>
            <li class="- topic/li "/>
            <p class="- topic/p "/>
            <prereq class="- topic/section task/prereq "/>
            <section class="- topic/section "/>
            <tm tmtype="reg" class="- topic/tm "/>
            <uicontrol class="+ topic/ph ui-d/uicontrol "/>
         </test_data>
      </xsl:variable>
      <test-results>
         <xsl:call-template name="testIsInline">
            <xsl:with-param name="test-data" select="$test-data"/>
         </xsl:call-template>
         <xsl:call-template name="testIsWrapMixed">
            <xsl:with-param name="test-data" select="$test-data"/>
         </xsl:call-template>
      </test-results>
   </xsl:template>

   <xsl:template name="testIsInline">
      <xsl:param name="test-data" required="yes"/>
      <xsl:variable name="tests" as="node()">
         <testcase name="ts:isInline tests">
            <test name="ts:isInline 1" pass="{not(ts:isInline($test-data/li))}">not li</test>
            <test name="ts:isInline 2" pass="{not(ts:isInline($test-data/p))}">not p</test>
            <test name="ts:isInline 3" pass="{not(ts:isInline($test-data/prereq))}">not prereq</test>
            <test name="ts:isInline 4" pass="{not(ts:isInline($test-data/section))}">not section</test>
            <test name="ts:isInline 5" pass="{ts:isInline($test-data/tm)}">tm</test>
            <test name="ts:isInline 6" pass="{ts:isInline($test-data/uicontrol)}">uicontrol</test>
         </testcase>
      </xsl:variable>
      <xsl:if test="$tests/test[@pass = 'false']">
         <failures name="ts:isInline tests">
            <xsl:apply-templates select="$tests"/>
         </failures>
      </xsl:if>
      <xsl:sequence select="$tests"/>
   </xsl:template>
   
   <xsl:template name="testIsWrapMixed">
      <xsl:param name="test-data" required="yes"/>
      <xsl:variable name="tests" as="node()">
         <testcase name="ts:isWrapMixed tests">
            <test name="ts:isWrapMixed 1" pass="{ts:isWrapMixed($test-data/li)}">li</test>
            <test name="ts:isWrapMixed 2" pass="{not(ts:isWrapMixed($test-data/p))}">not p</test>
            <test name="ts:isWrapMixed 3" pass="{ts:isWrapMixed($test-data/prereq)}">prereq</test>
            <test name="ts:isWrapMixed 4" pass="{ts:isWrapMixed($test-data/section)}">section</test>
            <test name="ts:isWrapMixed 5" pass="{not(ts:isWrapMixed($test-data/tm))}">not tm</test>
            <test name="ts:isWrapMixed 6" pass="{not(ts:isWrapMixed($test-data/uicontrol))}">not uicontrol</test>
         </testcase>
      </xsl:variable>
      <xsl:if test="$tests/test[@pass = 'false']">
         <failures name="ts:isWrapMixed tests">
            <xsl:apply-templates select="$tests"/>
         </failures>
      </xsl:if>
      <xsl:sequence select="$tests"/>
   </xsl:template>

   <xsl:template match="testcase">
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="test[@pass = 'false']">
      <fail name="{@name}">
         <xsl:apply-templates/>
      </fail>
   </xsl:template>  
   
   
   <xsl:template match="test[@pass = 'true']">
   </xsl:template>


</xsl:stylesheet>
