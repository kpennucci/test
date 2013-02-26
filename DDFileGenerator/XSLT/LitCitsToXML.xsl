<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="tpf"
  xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
  xmlns:tpf = "http://couplertools.pkc.com/schema/2011/02/PkcTpfDoc"
  xmlns     = "uri:PKC-DeepDive-GOSet"
 >

  <!--
   ************************************************************************
   ***********************   Source Type Templates   **********************
   ************************************************************************
   -->

  <!--
   ///////////////////////////
   // Source Type:  'Article'
   ///////////////////////////
   -->

  <xsl:template match="tpf:LitCit[@SourceType = 'Article']">
    <xsl:variable name="PoptID">
      <xsl:apply-templates select="ancestor::tpf:Popt" mode="GetIDString" />
    </xsl:variable>

    <Source id="{$PoptID}-{@SrcNo}"
      title="Source {@SrcNo}; {@SourceType}">

      <xsl:apply-templates select="@Authors" />
      <xsl:apply-templates select="@Title" />
      <xsl:apply-templates select="@JournalAbbr" />
      <xsl:call-template name="PublicationDate" />
      <xsl:apply-templates select="@Volume" />
      <xsl:apply-templates select="@Pages" />
      <xsl:apply-templates select="@URL" />

      <xsl:if test="@Facts">
        <br />
        <strong>
          Facts: <xsl:value-of select="@Facts"/>
        </strong>
        <xsl:text>.</xsl:text>
      </xsl:if>
    </Source>
  </xsl:template>

  <!--
   ////////////////////////
   // Source Type:  'Book'
   ////////////////////////
   -->

  <xsl:template match="tpf:LitCit[@SourceType = 'Book']">
    <xsl:variable name="PoptID">
      <xsl:apply-templates select="ancestor::tpf:Popt" mode="GetIDString" />
    </xsl:variable>

    <Source id="{$PoptID}-{@SrcNo}"
      title="Source {@SrcNo}; {@SourceType}">

      <xsl:apply-templates select="@Authors" />
      <xsl:apply-templates select="@Title" />
      <xsl:apply-templates select="@Edition" />
      <xsl:apply-templates select="@Publisher" />
      <xsl:call-template name="PublicationDate" />
      <xsl:apply-templates select="@URL" />

      <xsl:if test="@Facts">
        <br />
        <strong>
          Facts: <xsl:value-of select="@Facts"/>
        </strong>
        <xsl:text>.</xsl:text>
      </xsl:if>
    </Source>
  </xsl:template>

  <!--
   ////////////////////////////
   // Source Type:  'Document'
   ////////////////////////////
   -->

  <xsl:template match="tpf:LitCit[@SourceType = 'Document']">
    <xsl:variable name="PoptID">
      <xsl:apply-templates select="ancestor::tpf:Popt" mode="GetIDString" />
    </xsl:variable>

    <Source id="{$PoptID}-{@SrcNo}"
       title="Source {@SrcNo}; {@SourceType}">

      <xsl:apply-templates select="@Authors" />
      <xsl:apply-templates select="@Title" />
      <xsl:apply-templates select="@Edition" />
      <xsl:call-template name="PublicationDate" />
      <xsl:apply-templates select="@Chapter" />
      <xsl:apply-templates select="@ArticleTitle" />
      <xsl:apply-templates select="@URL" />

      <xsl:if test="@Facts">
        <br />
        <strong>
          Facts: <xsl:value-of select="@Facts"/>
        </strong>
        <xsl:text>.</xsl:text>
      </xsl:if>
    </Source>
  </xsl:template>

  <!--
   ************************************************************************
   *********************   Source Property Templates   ********************
   ************************************************************************
   -->

  <!--
   //////////////////////////////////////////////
   // Named templates, for conjoined properties.
   //////////////////////////////////////////////
   -->

  <xsl:template name="SrcNumAndType">
    <strong>#<xsl:value-of select="@SrcNo" /><xsl:text>, </xsl:text>
    <xsl:value-of select="@SourceType" />
    <xsl:apply-templates select="@PubType[../@SourceType = 'Document']" />
    </strong>
    <xsl:text>: </xsl:text>
  </xsl:template>

  <xsl:template name="PublicationDate">

    <xsl:value-of select="@PubYear" />
    <xsl:if test="@PubMonth != 0">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="@PubMonth" />
    </xsl:if>
    <xsl:if test="@PubDay != 0">
      <xsl:value-of select="concat(' ',@PubDay)" />
    </xsl:if>

    <xsl:choose>
      <xsl:when test="@SourceType = 'Article'">
        <xsl:text>;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>. </xsl:text>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- Supports the 'PublicationDate' template. -->

  <xsl:template match="@PubMonth">
    <xsl:call-template name="MonthNumToAbbr" />
  </xsl:template>

  <!--
   /////////////////////////////////////////////////////////////
   // Attribute matching templates, for other Source properties.
   /////////////////////////////////////////////////////////////
   -->

  <xsl:template match="@ArticleTitle[string-length() != 0]">
    <xsl:value-of select="." />
    <xsl:text>.</xsl:text>
  </xsl:template>

  <xsl:template match="@Authors">
    <xsl:variable name="NoAuthors" select="../@NoAuthors = '1'" />
    <xsl:variable name="EtAl"      select="../@EtAl = '1'" />

    <xsl:choose>
      <xsl:when test="$NoAuthors">
        <xsl:text>[no authors listed]. </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
        <xsl:if test="$EtAl">, et al</xsl:if>
        <xsl:text>. </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@Chapter[string-length() != 0]">
    <xsl:text>Chapter </xsl:text>
    <xsl:value-of select="." />
    <xsl:text>,</xsl:text>
  </xsl:template>

  <xsl:template match="@Edition[string-length() != 0]">
    <xsl:call-template name="NumberWithSuffix" />
    <xsl:text> ed. </xsl:text>
  </xsl:template>

  <xsl:template match="@Issue[string-length() != 0]">
    <xsl:value-of select="concat('(',.,')')" />
  </xsl:template>

  <xsl:template match="@JournalAbbr">
    <Accent><xsl:value-of select="." /></Accent>
    <xsl:apply-templates select="../@Medium[. != 'Print']" />
    <xsl:text>.</xsl:text>
  </xsl:template>

  <xsl:template match="@Medium">
    <xsl:value-of select="concat(' [',.,']')" />
  </xsl:template>

  <xsl:template match="@Pages">
    <xsl:value-of select="." /><xsl:text>.</xsl:text>
  </xsl:template>

  <xsl:template match="@Publisher">
    <xsl:value-of select="." />
    <xsl:text>;</xsl:text>
  </xsl:template>

  <xsl:template match="@PubType[string-length() != 0]">
    <xsl:value-of select="concat(' [',.,']')" />
  </xsl:template>

  <xsl:template match="@Title[../@SourceType != 'Article']">
    <Accent><xsl:value-of select="." /></Accent>
    <xsl:apply-templates select="../@Medium[. != 'Print']" />
    <xsl:text>.</xsl:text>
  </xsl:template>

  <xsl:template match="@Title[../@SourceType = 'Article']">
    <xsl:call-template name="ApplyPeriodSuffix" />
  </xsl:template>

  <xsl:template match="@URL[string-length() != 0]">
    <Url>Accessed at: <xsl:value-of select="." /></Url>
  </xsl:template>

  <xsl:template match="@Volume">
    <xsl:value-of select="." />
    <xsl:apply-templates select="../@Issue" />
    <xsl:text>:</xsl:text>
  </xsl:template>

  <!--
   ************************************************************************
   *************************   Helper Templates   *************************
   ************************************************************************
   -->

  <!--
   /////////////////////////////////////////////////////////
   // Apply a period suffix, i.e., a period + space [". "]:
   //
   // If the value being suffixed already ends with a period,
   // or ends with a question mark (?), just append a space.
   /////////////////////////////////////////////////////////
   -->

  <xsl:template name="ApplyPeriodSuffix">
    <xsl:variable name="LastChar" select="substring(., string-length(.), 1)" />

    <xsl:value-of select="."/>
    <xsl:if test="$LastChar != '.' and $LastChar != '?'">
      <xsl:text>.</xsl:text>
    </xsl:if>
    <xsl:text> </xsl:text>
  </xsl:template>

  <!--
   ///////////////////////////////////////////////////////////////
   // Number with suffix:
   //   "1" becomes "1st", "2" becomes "2nd",
   //   "3" becomes "3rd", "4" becomes "4th", etc.
   //   "11", "12",...., "20" becomes "11th", "12th",...., "20th"
   ///////////////////////////////////////////////////////////////
   -->

  <xsl:template name="NumberWithSuffix">
    <xsl:variable name="Num" select="number(.)" />

    <xsl:if test="string($Num) = 'NaN'">
      <xsl:value-of select="."/>
    </xsl:if>

    <xsl:if test="string($Num) != 'NaN'">
      <xsl:value-of select="$Num"/>
      <NumSuffix>
        <xsl:choose>
          <xsl:when test="$Num &gt;= 11 and $Num &lt;= 13">
            <xsl:text>th</xsl:text>
          </xsl:when>
          <xsl:when test="($Num mod 10) = 1">
            <xsl:text>st</xsl:text>
          </xsl:when>
          <xsl:when test="($Num mod 10) = 2">
            <xsl:text>nd</xsl:text>
          </xsl:when>
          <xsl:when test="($Num mod 10) = 3">
            <xsl:text>rd</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>th</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </NumSuffix>
    </xsl:if>
  </xsl:template>

  <!--
   //////////////////////////////////////////////////////
   // Translate month number to a 3-letter abbreviation:
   //   "1" becomes "Jan", "2" becomes "Feb",
   //   "3" becomes "Mar", "4" becomes "Apr", etc.
   //   Out of range (not 1-12) becomes "???".
   //////////////////////////////////////////////////////
   -->

  <xsl:template name="MonthNumToAbbr">
    <xsl:variable name="MonthNum" select="number(.)" />

    <xsl:if test="string($MonthNum) = 'NaN'">
      <xsl:value-of select="."/>
    </xsl:if>

    <xsl:if test="string($MonthNum) != 'NaN'">
      <xsl:choose>
        <xsl:when test="$MonthNum =  1">Jan</xsl:when>
        <xsl:when test="$MonthNum =  2">Feb</xsl:when>
        <xsl:when test="$MonthNum =  3">Mar</xsl:when>
        <xsl:when test="$MonthNum =  4">Apr</xsl:when>
        <xsl:when test="$MonthNum =  5">May</xsl:when>
        <xsl:when test="$MonthNum =  6">Jun</xsl:when>
        <xsl:when test="$MonthNum =  7">Jul</xsl:when>
        <xsl:when test="$MonthNum =  8">Aug</xsl:when>
        <xsl:when test="$MonthNum =  9">Sep</xsl:when>
        <xsl:when test="$MonthNum = 10">Oct</xsl:when>
        <xsl:when test="$MonthNum = 11">Nov</xsl:when>
        <xsl:when test="$MonthNum = 12">Dec</xsl:when>

        <xsl:otherwise>???</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
