<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ts="http://tagsmiths.com/dita/functions"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:df="http://dita2indesign.org/dita/functions"
   version="2.0">
   
   
   <xsl:import href="relpath_util.xsl"/>
   <xsl:import href="dita-support-lib.xsl"/>


   <!-- RESTRICTION: An element can only appear here if the <p> element allows it as a child. -->
   <xsl:function name="ts:isInline" as="xs:boolean">
      <xsl:param name="elem"/>
      <xsl:variable name="result" as="xs:boolean">
         <xsl:choose>
            <!-- Don't treat task/cmd as an inline even though it is a specializtion
             of topic/ph. Add other such exceptions here, as needed. -->
            <xsl:when test="df:class($elem, 'task/cmd')">
               <xsl:value-of select="false()"/>
            </xsl:when>
            <!-- Classes that are more likely to occur have been put near the front
            so that the XSLT processor can exit the test sooner. Note that this function
            will also match an element that is a specialization of any of these classes
            (except for <cmd>). -->
            <xsl:when
               test="df:class($elem, 'topic/ph')
               or df:class($elem, 'topic/indexterm')
               or df:class($elem, 'topic/keyword')
               or df:class($elem, 'topic/xref')
               or df:class($elem, 'topic/alt')
               or df:class($elem, 'topic/boolean')
               or df:class($elem, 'topic/cite')
               or df:class($elem, 'topic/data')
               or df:class($elem, 'topic/data-about')
               or df:class($elem, 'topic/draft-comment')
               or df:class($elem, 'topic/fn')
               or df:class($elem, 'topic/foreign')
               or df:class($elem, 'topic/image')
               or df:class($elem, 'topic/index-base')
               or df:class($elem, 'topic/indextermref')
               or df:class($elem, 'topic/q')
               or df:class($elem, 'topic/required-cleanup')
               or df:class($elem, 'topic/state')
               or df:class($elem, 'topic/term')
               or df:class($elem, 'topic/text')
               or df:class($elem, 'topic/tm')
               or df:class($elem, 'topic/unknown')">
               <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="false()"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:sequence select="$result"/>
   </xsl:function>
   

   <!-- RESTRICTION: These elements must allow <p> as a child element. -->
   <!-- Note that this function will also match an element that is a
        specialization of any of these classes -->
   <xsl:function name="ts:isWrapMixed" as="xs:boolean">
      <xsl:param name="elem"/>
      <xsl:variable name="result"
         select="
         df:class($elem, 'topic/abstract') or
         df:class($elem, 'topic/bodydiv') or
         df:class($elem, 'topic/dd') or
         df:class($elem, 'topic/entry') or
         df:class($elem, 'topic/example') or
         df:class($elem, 'topic/itemgroup') or
         df:class($elem, 'topic/li') or
         df:class($elem, 'topic/lines') or
         df:class($elem, 'topic/lq') or
         df:class($elem, 'topic/note') or
         df:class($elem, 'topic/section') or
         df:class($elem, 'topic/sectiondiv') or
         df:class($elem, 'topic/stentry')
         "
         as="xs:boolean"/>
      <xsl:sequence select="$result"/>
   </xsl:function>

</xsl:stylesheet>
