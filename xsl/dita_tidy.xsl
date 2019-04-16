<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
   xmlns:df="http://dita2indesign.org/dita/functions"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:map="http://www.w3.org/2005/xpath-functions/map"
   exclude-result-prefixes="df ditaarch map"
   version="3.0"
   expand-text="yes"
   >
<!-- This transform takes DITA content and wraps mixed content with the <p>
     element for all elements identified by the ts:isWrapMixed() boolean
     function. The ts:isWrapMixed() function definition is in file
     ts_dita_tidy_util.xsl. Edit the function definition to add or remove
     elements identified for wrapping.
     
     Parameters:
     
       preservePIs: Preserve processing instructions. The default value 'yes'.
     
       preserveComments: Preserve comments. The default value is 'yes'.
     
       outputfile: Output file name. The default value is 'out.xml'.
     
     
     Output: This transform sends its output to the file specified in the
     outfile parameter.
     
     Dependencies: This module depends upon ts_dita_tidy_util
     
     Use cases:
     1. Simplify output stylesheet logic by reducing the number of mixed-content
     contexts that a stylesheet has to consider. This can be especially helpful
     when writing logic to render lists and tables.
     2. Convert out-of-the-box DITA to constrained versions of DITA that do not
     allow mixed content in certain places.
     
     Author: Bob Thomas, bob.thomas@tagsmiths.com
-->

   <xsl:mode on-no-match="shallow-copy"/>
   
   <!-- currentFile is unused. It could be used with the ant 'xslt' task's
      filenameparameter attribute. -->
   <xsl:param name="currentFile"/>
   <xsl:param name="preservePIs">yes</xsl:param>
   <xsl:param name="preserveComments">yes</xsl:param>
   <!-- For applications that use the ant 'xslt' task to process several topics,
      you may wish to change outputfile from a paramater to a variable that uses
      the value of the currentFile parameter as part of its name -->
   <!--<xsl:param name="outputfile">out.xml</xsl:param>-->
   <xsl:param name="outputfile">/home/rnt/sandbox/foo.xml</xsl:param>

   <xsl:strip-space elements="*"/>
   <xsl:preserve-space elements="pre lines codeblock"/>
   
   <xsl:variable name="doctypeMap" as="map(*)"
      select="
      map{
      'concept' : '-//OASIS//DTD DITA Concept//EN',
      'reference' : '-//OASIS//DTD DITA Reference//EN',
      'task' : '-//OASIS//DTD DITA Task//EN',
      'topic' : '-//OASIS//DTD DITA Topic//EN',
      'dita' : '-//OASIS//DTD DITA Composite//EN'
      }
      "
   />

   <xsl:output method="xml" indent="no"/>

   <xsl:template name="dita-tidy" match="/">
      <xsl:variable name="rootElement" as="xs:string" select="name(/*[1])"/>
      <xsl:variable name="publicDoctype" as="xs:string"
         select="map:get($doctypeMap, $rootElement)
         "
      />

      <xsl:variable name="systemId" as="xs:string"
         select="
         'urn:' || 
         (if ($rootElement eq 'dita')
          then 'ditabase'
          else $rootElement
         )
         || '.dtd'"
      />
      <xsl:result-document method="xml" indent="no" doctype-public="{$publicDoctype}"
         doctype-system="{$systemId}" href="{$outputfile}">
         <xsl:apply-templates/>
      </xsl:result-document>
   </xsl:template>

   <xsl:template match="*">
      <xsl:copy copy-namespaces="no">
         <xsl:apply-templates select="@*"/>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="*[df:isWrapMixed(.)]">
      <xsl:call-template name="wrap-mixed-content"/>
   </xsl:template>

   <xsl:template name="wrap-mixed-content">
      <!-- buffer intermediate output where all text() is wrapped in
            <rawtext wrapWithP="yes"> and all inline elements have 
            @wrapWithP="yes". Later, this buffer will be processed
            by "xsl:for-each-group, group-adjacent" to wrap contiguous
            text() and inline elements with <p> elements.
        -->
      <xsl:variable name="wrapped-text-buffer">
         <xsl:apply-templates mode="populate-wrapped-text-buffer"/>
      </xsl:variable>
      <xsl:copy copy-namespaces="no">
         <xsl:apply-templates select="@*"/>
         <!-- Iterate over the top-level nodes in wrapped-text-buffer, wrapping
              all contiguous *[@wrapWithP='yes'] in a single <p> element. The
              template rule that matches the temporary <rawtext> element
              unwraps the <rawtext> tags surronding the text.
            -->
         <xsl:for-each-group select="$wrapped-text-buffer/*"
            group-adjacent="boolean(self::*[@wrapWithP = 'yes'])">
            <xsl:choose>
               <xsl:when test="current-grouping-key()">
                  <xsl:element name="p">
                     <xsl:apply-templates select="current-group()" mode="wrap"/>
                  </xsl:element>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates select="current-group()"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each-group>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="rawprocessing-instruction">
      <xsl:choose>
         <xsl:when test="$preservePIs = 'yes'">
            <xsl:processing-instruction name="{@name}"><xsl:value-of select="."/></xsl:processing-instruction>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   
   <xsl:template 
      match="@class |
      @ditaarch:* |
      @domains |
      @wrapWithP |
      @*[starts-with(name(.),'ish')]
      ">
      <!-- Suppress -->
   </xsl:template>

   <xsl:template match="text()">
      <xsl:value-of select="normalize-space(.)"/>
   </xsl:template>

   <xsl:template match="comment()">
      <xsl:if test="$preserveComments = 'yes'">
         <xsl:sequence select="."/>
      </xsl:if>
   </xsl:template>

   <xsl:template match="processing-instruction()">
      <xsl:choose>
         <xsl:when test="$preservePIs = 'yes'">
            <xsl:sequence select="."/>
         </xsl:when>
      </xsl:choose>
   </xsl:template>


   <!-- BEGIN templates for mode populate-wrapped-text-buffer -->
   <xsl:template match="text()" mode="populate-wrapped-text-buffer">
      <!-- If the text() contains something other than white-space,
         then wrap it with temporary element <rawtext wrapWithText="yes">
      -->
      <xsl:if test="normalize-space(.) != ''">
         <xsl:element name="rawtext">
            <xsl:attribute name="wrapWithP">yes</xsl:attribute>
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:element>
      </xsl:if>
   </xsl:template>

   <xsl:template match="comment()" mode="populate-wrapped-text-buffer">
      <!-- Preserve XML comments -->
      <xsl:if test="$preserveComments = 'yes'">
         <xsl:element name="rawcomment">
            <xsl:attribute name="wrapWithP">yes</xsl:attribute>
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:element>
      </xsl:if>
   </xsl:template>

   <xsl:template match="processing-instruction()" mode="populate-wrapped-text-buffer">
      <!-- Preserve processing instructions -->
      <xsl:if test="$preservePIs = 'yes'">
         <xsl:element name="rawprocessing-instruction">
            <xsl:attribute name="name">
               <xsl:value-of select="name(.)"/>
            </xsl:attribute>
            <xsl:attribute name="wrapWithP">yes</xsl:attribute>
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:element>
      </xsl:if>
   </xsl:template>

   <xsl:template match="*[df:isInline(.)]" mode="populate-wrapped-text-buffer">
      <!-- When the element is an inline, add temporary attribute wrapWithP. -->
      <xsl:element name="{name(.)}">
         <xsl:apply-templates select="@*"/>
         <xsl:attribute name="wrapWithP">yes</xsl:attribute>
         <xsl:apply-templates/>
      </xsl:element>
   </xsl:template>

   <xsl:template match="*" mode="populate-wrapped-text-buffer">
      <xsl:apply-templates select="."/>
   </xsl:template>
   <!-- END templates for mode populate-wrapped-text-buffer -->


   <!-- BEGIN templates for mode wrap -->
   <!-- Only elements previously identified as inlines are submitted with mode "wrap".-->
   <xsl:template match="*" mode="wrap">
      <!-- Spacing around inline elements is absorbed during paragraph wrapping. 
           Threfore, a space is inserted when the inline is not the first child.
      -->
      <xsl:if test="not(position()=1)">
         <xsl:text>&#x20;</xsl:text>
      </xsl:if>
      <xsl:apply-templates select="."/>
   </xsl:template>

   <xsl:template match="rawtext" mode="wrap">
      <xsl:choose>
         <!-- This element's position() context is with respect to the
                 current-grouping-key() which is often different than the
                 original text() node's position in its parent.
            -->
         <xsl:when test="position()=1">
            <!-- No leading space needed. -->
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:when>
         <xsl:otherwise>
            <!-- Stuffs a space character in front whenever the
                 first charcter is not associated with punctuation.
            -->
            <xsl:value-of
               select="replace(normalize-space(.), '^([^.^,^;^:^?^!^)^\]^}^>^\-])', ' $1', 'i')"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="rawcomment" mode="wrap">
      <xsl:if test="$preserveComments = 'yes'">
         <xsl:sequence select="."/>
      </xsl:if>
   </xsl:template>
   <!-- END templates for mode wrap -->

</xsl:stylesheet>
