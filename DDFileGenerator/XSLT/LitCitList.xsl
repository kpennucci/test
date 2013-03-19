<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  exclude-result-prefixes    = "tpf"
  extension-element-prefixes = "extf"

  xmlns:xsl  = "http://www.w3.org/1999/XSL/Transform"
  xmlns:tpf  = "http://couplertools.pkc.com/schema/2011/02/PkcTpfDoc"
  xmlns:extf = "urn:schemas-microsoft-com:xslt"
  xmlns      = "uri:PKC-DeepDive-GOSet"
 >

 <!-- xmlns:extf = "http://exslt.org/common" -->
 <!-- xmlns:extf = "urn:schemas-microsoft-com:xslt" -->

  <!--
   ************************************************************************
   *****************   Footnote Reference List Generator   ****************
   ************************************************************************
   -->

  <!--
   ////////////////////////////////////////////////////////////////
   // Render embedded literature citations as footnote references.
   ////////////////////////////////////////////////////////////////
   -->

  <xsl:template match="tpf:LitCitList" mode="FootnoteRefs">
    <xsl:if test="count (tpf:LitCit) &gt; 0">
      <RefList>
        <xsl:variable name="Refs">
          <xsl:apply-templates select="tpf:LitCit" mode="FootnoteRefs">
            <xsl:sort select="@SrcNo" data-type="number" order="ascending" />
          </xsl:apply-templates>
        </xsl:variable>

        <xsl:copy-of select="extf:node-set($Refs)"/>
      </RefList>
    </xsl:if>
  </xsl:template>

  <!--
   ////////////////////////////////////////////////////////////////////
   // Render an embedded literature citation as a hyperlinked footnote
   // reference.
   ////////////////////////////////////////////////////////////////////
   -->

  <xsl:template match="tpf:LitCit" mode="FootnoteRefs">
    <xsl:variable name="PoptSources">
      <xsl:for-each select="ancestor::tpf:Popt/tpf:LitCitList/tpf:LitCit">
        <xsl:sort select="@Author" order="ascending"/>
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="PoptID">
      <xsl:apply-templates select="ancestor::tpf:Popt" mode="GetIDString" />
    </xsl:variable>

    <xsl:variable name="ThisSrcNo" select="string(current()/@SrcNo)"/>
    <xsl:variable name="LastSrcNo" select="string(preceding-sibling::*[@SrcNo = $ThisSrcNo]/@SrcNo)"/>

    <xsl:if test="$LastSrcNo != $ThisSrcNo">
      <xsl:for-each select="extf:node-set($PoptSources)//@SrcNo">
        <xsl:if test=". = $ThisSrcNo">
          <Ref Id="{$PoptID}-{$ThisSrcNo}">
            <xsl:value-of select="position ()"/>
          </Ref>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <!--
   /////////////////////////////////////////////////////////////////////
   // HELPER TEMPLATES:  Build a unique ID string for a Guidance Option
   // (Popt).
   /////////////////////////////////////////////////////////////////////
   -->

  <xsl:template match="tpf:Popt" mode="GetIDString">
    <xsl:variable name="PoptCatOrdinal">
      <xsl:apply-templates select="ancestor::tpf:PoptCat" mode="GetIDString" />
    </xsl:variable>

    <xsl:value-of select="$PoptCatOrdinal"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="count(preceding-sibling::*) + 1"/>
  </xsl:template>

  <xsl:template match="tpf:PoptCat" mode="GetIDString">
    <xsl:value-of select="string(count(preceding-sibling::*) + 1)"/>
  </xsl:template>

</xsl:stylesheet>