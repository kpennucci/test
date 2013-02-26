<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="tpf"
  xmlns:xsl   = "http://www.w3.org/1999/XSL/Transform"
  xmlns:tpf   = "http://couplertools.pkc.com/schema/2011/02/PkcTpfDoc"
  xmlns       = "uri:PKC-DeepDive-GOSet"
>
  <!--
   ************************************************************************
   ***********************   Imported Stylesheets   ***********************
   ************************************************************************
   -->

  <xsl:import href="LitCitList.xsl" />
  <xsl:import href="LitCitsToXML.xsl" />

  <!--
   ************************************************************************
   **************************   Output Settings   *************************
   ************************************************************************
   -->

  <xsl:output
    method               = "xml"
    version              = "1.0"
    encoding             = "UTF-8"
    omit-xml-declaration = "no"
    standalone           = "yes"
    indent               = "yes"
    media-type           = "text/xml"
  />


  <!--
   ************************************************************************
   ****************************   Parameters   ****************************
   ************************************************************************
   -->

  <xsl:param name="EntityNumber" />

  <!--
   ************************************************************************
   *************************   Global Variables   *************************
   ************************************************************************
   -->

  <xsl:variable name="Titles"                select="document('GODirectory.xml')" />
  <xsl:variable name="CouplerNumber"         select="tpf:PkcTpfDoc/tpf:Advisor/@Number" />

  <!--
   ************************************************************************
   *************************   Document Template   ************************
   ************************************************************************
   -->

  <!--
   ///////////////////////////
   // XML Document Generator
   ///////////////////////////
   -->
  <xsl:template match="tpf:PkcTpfDoc">
    <xsl:processing-instruction name="xml-stylesheet">
      <xsl:text>href="XSLT/DDtoXHTML.xsl" type="text/xsl"</xsl:text>
    </xsl:processing-instruction>
    <xsl:apply-templates select="tpf:Advisor" />
  </xsl:template>

  <!--
   ///////////////////////////////////////////////////////////////////////////
   // 'Advisor' element:  Identifies the overall clinical problem context and
   // PKC's unique numeric identifier for this content module.
   ///////////////////////////////////////////////////////////////////////////
   -->
  <xsl:template match="tpf:Advisor" >
    <PkcGuidanceSet>
      <xsl:attribute name="Num">
        <xsl:value-of select="@Number" />
      </xsl:attribute>
      <xsl:attribute name="Name">
        <xsl:value-of select="@Name" />
      </xsl:attribute>

      <xsl:choose>
        <xsl:when test="$EntityNumber = ''" >
          <xsl:apply-templates select="tpf:PoptCat/tpf:Popt" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="tpf:PoptCat/tpf:Popt[$EntityNumber = @EntNo]" />
        </xsl:otherwise>
      </xsl:choose>
     </PkcGuidanceSet>
   </xsl:template>

  <!--
   ///////////////////////////////////////////////////////////////////////////
   // Elements:  'Popt'
   //
   // These are the diagnoses or disease management options included in the
   // document. PKC refers to these as "Guidance Options", because they and
   // their associated information ("details") are intended to provide guidance
   // to a clinical decision-maker in selecting possible diagnoses for a
   // problem, or options for managing a problem (resolving the underlying
   // cause, treating symptoms and complications, addressing impacts on the
   // patient's work and personal life).
   ///////////////////////////////////////////////////////////////////////////
   -->

  <xsl:template match="tpf:Popt" >
    <xsl:variable name="EntNo">
      <xsl:value-of select="@EntNo" />
    </xsl:variable>

    <xsl:variable name="DODirNode" select="$Titles/GuidanceOptionDirectory/GuidanceOption[CouplerNumber=$CouplerNumber][GOGEN=$EntNo]" />

    <xsl:choose>
      <xsl:when test="$DODirNode/DDType='DD_Tx'" >
        <xsl:apply-templates select="." mode="Treatment" >
          <xsl:with-param name="GODirNode" select="$DODirNode" />
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$DODirNode/DDType='DD_Dx'" >
        <xsl:apply-templates select="." mode="Diagnostic" >
          <xsl:with-param name="GODirNode" select="$DODirNode" />
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$DODirNode/DDType='DD_Scr'" >
        <xsl:apply-templates select="." mode="Screening" >
          <xsl:with-param name="GODirNode" select="$DODirNode" />
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <!--
   ///////////////////////////////////////////////////////////////////////////
   // Elements:  'Popt'
   // Mode:      'Diagnostic'
   // 
   // Handle diagnostic Guidance Options.
   ///////////////////////////////////////////////////////////////////////////
   -->

  <xsl:template match="tpf:Popt" mode="Diagnostic">
    <xsl:param name="GODirNode" />

    <Guidance>
      <xsl:attribute name="DDType">
        <xsl:value-of select="$GODirNode/DDType" />
      </xsl:attribute>
      <xsl:attribute name="EntNo">
        <xsl:value-of select="@EntNo" />
      </xsl:attribute>
      <xsl:attribute name="Name">
        <xsl:value-of select="@Name" />
      </xsl:attribute>

      <Section>
        <xsl:attribute name="Name">
          <xsl:text>Summary</xsl:text>
        </xsl:attribute>
        <Title>
          <xsl:value-of select="$GODirNode/DDTitle" />
        </Title>
        <!-- List Comments with DisplayWeight 650-800 -->
        <xsl:apply-templates
          select="tpf:PoptCmt/tpf:CmtList/tpf:CmtInfo[@DWgt&lt;=800][@DWgt&gt;=650]" />
      </Section>

      <xsl:if test="$GODirNode/DDFinding != 'Suppress' and tpf:FindingsEvidOrPro" >
        <Section>
          <xsl:attribute name="Name">
            <xsl:text>KeySignsSymptoms</xsl:text>
          </xsl:attribute>
          <Title>
            <xsl:text>Key Signs &amp; Symptoms of </xsl:text>
            <xsl:value-of select="@Name" />
          </Title>
          <Comment>
            <xsl:attribute name="Type">
              <xsl:text>Intro</xsl:text>
            </xsl:attribute>
            <Text>
              <xsl:text>To find the cause of a problem, a doctor needs to know about current signs and symptoms. A sign is something the doctor can observe or detect, such as a rapid heart rate. A symptom is something that can’t be observed, such as feeling short of breath.</xsl:text>
            </Text>
          </Comment>
          <Comment>
            <xsl:attribute name="Type">
              <xsl:text>Intro</xsl:text>
            </xsl:attribute>
            <Text>
              <xsl:text>The signs and symptoms below can help distinguish between possible causes of the problem. However, this is not a complete list of signs and symptoms.</xsl:text>
            </Text>
          </Comment>
          <!-- List Evidence -->
          <xsl:apply-templates select="tpf:FindingsEvidOrPro" >
            <xsl:with-param name="DDFinding" select="$GODirNode/DDFinding" />
          </xsl:apply-templates>
          <!-- List Comments with DisplayWeight 500-600 -->
          <xsl:apply-templates
             select="tpf:PoptCmt/tpf:CmtList/tpf:CmtTitle[@DWgt&lt;=600][@DWgt&gt;=500] |
                  tpf:PoptCmt/tpf:CmtList/tpf:CmtInfo[@DWgt&lt;=600][@DWgt&gt;=500]" />
        </Section>
      </xsl:if>

      <xsl:if test="tpf:PlanOptions" >
        <Section>
          <xsl:attribute name="Name">
            <xsl:text>ConfirmingTheDx</xsl:text>
          </xsl:attribute>
          <Title>Confirming the Diagnosis</Title>
          <Comment>
            <xsl:attribute name="Type">
              <xsl:text>Intro</xsl:text>
            </xsl:attribute>
            <Text>
              <xsl:text>After considering signs and symptoms, a doctor may need the results of one or more tests to make a diagnosis. These could include blood tests, x-rays or scans, genetic testing, or other diagnostic procedures.</xsl:text>
            </Text>
          </Comment>
          <!-- List Plan Options -->
          <xsl:apply-templates select="tpf:PlanOptions" />
        </Section>
      </xsl:if>

      <xsl:if test="tpf:PoptCmt/tpf:CmtList/tpf:CmtTitle[@DWgt&lt;=500] |
                  tpf:PoptCmt/tpf:CmtList/tpf:CmtInfo[@DWgt&lt;=500]">
        <Section>
          <xsl:attribute name="Name">
            <xsl:text>FurtherInfo</xsl:text>
          </xsl:attribute>
          <Title>Further Information</Title>
          <!-- List Comments with DisplayWeight <= 500 -->
          <xsl:apply-templates
           select="tpf:PoptCmt/tpf:CmtList/tpf:CmtTitle[@DWgt&lt;=500] |
              tpf:PoptCmt/tpf:CmtList/tpf:CmtInfo[@DWgt&lt;=500]" />
        </Section>
      </xsl:if>

      <xsl:if test="tpf:LitCitList" >
        <Section>
          <xsl:attribute name="Name">
            <xsl:text>Sources</xsl:text>
          </xsl:attribute>
          <Title>Sources</Title>
          <Comment>
            <xsl:attribute name="Type">
              <xsl:text>Intro</xsl:text>
            </xsl:attribute>
            <Text>
              <xsl:text>Details about this condition, its signs, symptoms, and diagnostic guidelines, were drawn from the following medical texts or medical journal articles.</xsl:text>
            </Text>
          </Comment>
          <xsl:apply-templates select="tpf:LitCitList" />
        </Section>
      </xsl:if>

    </Guidance>
  </xsl:template>

  <!--
   ///////////////////////////////////////////////////////////////////////////
   // Elements:  'Popt'
   // Mode:      'Treatment'
   // 
   // Handle treatment Guidance Options.
   ///////////////////////////////////////////////////////////////////////////
   -->

  <xsl:template match="tpf:Popt" mode="Treatment">
    <xsl:param name="GODirNode" />

    <Guidance>
      <xsl:attribute name="DDType">
        <xsl:value-of select="$GODirNode/DDType" />
      </xsl:attribute>
      <xsl:attribute name="EntNo">
        <xsl:value-of select="@EntNo" />
      </xsl:attribute>
      <xsl:attribute name="Name">
        <xsl:value-of select="@Name" />
      </xsl:attribute>

      <Section>
        <xsl:attribute name="Name">
          <xsl:text>Summary</xsl:text>
        </xsl:attribute>
        <Title>
          <xsl:value-of select="$GODirNode/DDTitle" />
        </Title>
        <!-- List Comments with DisplayWeight 650-800 -->
        <xsl:apply-templates
          select="tpf:PoptCmt/tpf:CmtList/tpf:CmtInfo[@DWgt&lt;=800][@DWgt&gt;=650]" />
      </Section>

      <xsl:if test="$GODirNode/DDFinding != 'Suppress' and tpf:FindingsEvidOrPro" >
        <Section>
          <xsl:attribute name="Name">
            <xsl:text>KeyConsiderations</xsl:text>
          </xsl:attribute>
          <Title>
            <xsl:text>Key Considerations</xsl:text>
          </Title>
          <Comment>
            <xsl:attribute name="Type">
              <xsl:text>Intro</xsl:text>
            </xsl:attribute>
            <Text>
              <xsl:text>To determine whether this is the right treatment, a doctor needs to consider a person’s medical history. The following might make this a good treatment choice.</xsl:text>
            </Text>
          </Comment>
          <!-- List Evidence -->
          <xsl:apply-templates select="tpf:FindingsEvidOrPro" >
            <xsl:with-param name="DDFinding" select="$GODirNode/DDFinding" />
          </xsl:apply-templates>
        </Section>
      </xsl:if>

      <xsl:if test="tpf:FindingsRiskOrCon" >
        <Section>
          <xsl:attribute name="Name">
            <xsl:text>Cautions</xsl:text>
          </xsl:attribute>
          <Title>Cautions</Title>
          <Comment>
            <xsl:attribute name="Type">
              <xsl:text>Intro</xsl:text>
            </xsl:attribute>
            <Text>
              <xsl:text>Some medical conditions, medications, and hereditary factors can interfere with treatment or cause unwanted side effects. The following are reasons to be cautious.</xsl:text>
            </Text>
          </Comment>
          <!-- List Cons -->
          <xsl:apply-templates select="tpf:FindingsRiskOrCon" />
        </Section>
      </xsl:if>

      <xsl:if test="tpf:PoptCmt/tpf:CmtList/tpf:CmtTitle[@DWgt&lt;=650] |
                  tpf:PoptCmt/tpf:CmtList/tpf:CmtInfo[@DWgt&lt;=650]    |
                  tpf:PlanOptions">
        <Section>
          <xsl:attribute name="Name">
            <xsl:text>FurtherInfo</xsl:text>
          </xsl:attribute>
          <Title>Further Information</Title>
          <!-- List Comments with DisplayWeight <= 650 -->
          <xsl:apply-templates
           select="tpf:PoptCmt/tpf:CmtList/tpf:CmtTitle[@DWgt&lt;=650] |
              tpf:PoptCmt/tpf:CmtList/tpf:CmtInfo[@DWgt&lt;=650]" />
          <!-- List Plan Options -->
          <xsl:apply-templates select="tpf:PlanOptions" />
        </Section>
      </xsl:if>

      <xsl:if test="tpf:LitCitList" >
        <Section>
          <xsl:attribute name="Name">
            <xsl:text>Sources</xsl:text>
          </xsl:attribute>
          <Title>Sources</Title>
          <Comment>
            <xsl:attribute name="Type">
              <xsl:text>Intro</xsl:text>
            </xsl:attribute>
            <Text>
              <xsl:text>Details about this treatment, such as its effectiveness and side effects, come from the following medical texts or medical journal articles.</xsl:text>
            </Text>
          </Comment>
          <xsl:apply-templates select="tpf:LitCitList" />
        </Section>
      </xsl:if>

    </Guidance>
  </xsl:template>

  <!--
   ///////////////////////////////////////////////////////////////////////////
   // Elements:  'Popt'
   // Mode:      'Screening'
   // 
   // Handle screening Guidance Options.
   ///////////////////////////////////////////////////////////////////////////
   -->

  <xsl:template match="tpf:Popt" mode="Screening">
    <xsl:param name="GODirNode" />

    <Guidance>
      <xsl:attribute name="DDType">
        <xsl:value-of select="$GODirNode/DDType" />
      </xsl:attribute>
      <xsl:attribute name="EntNo">
        <xsl:value-of select="@EntNo" />
      </xsl:attribute>
      <xsl:attribute name="Name">
        <xsl:value-of select="@Name" />
      </xsl:attribute>

      <Section>
        <xsl:attribute name="Name">
          <xsl:text>Summary</xsl:text>
        </xsl:attribute>
        <Title>
          <xsl:value-of select="$GODirNode/DDTitle" />
        </Title>
        <xsl:apply-templates
          select="tpf:PoptCmt/tpf:CmtList/tpf:CmtTitle |
                  tpf:PoptCmt/tpf:CmtList/tpf:CmtInfo" />
      </Section>

      <xsl:if test="$GODirNode/DDFinding != 'Suppress' and tpf:FindingsEvidOrPro" >
        <Section>
          <xsl:attribute name="Name">
            <xsl:text>KeyConsiderations</xsl:text>
          </xsl:attribute>
          <Title>
            <xsl:text>Key Considerations</xsl:text>
          </Title>
          <Comment>
            <xsl:attribute name="Type">
              <xsl:text>Intro</xsl:text>
            </xsl:attribute>
            <Text>
              <xsl:text>To determine whether this is the relevant, a doctor needs to consider a person’s medical history. The following might make this a good choice.</xsl:text>
            </Text>
          </Comment>
          <!-- List Evidence -->
          <xsl:apply-templates select="tpf:FindingsEvidOrPro" >
            <xsl:with-param name="DDFinding" select="$GODirNode/DDFinding" />
          </xsl:apply-templates>
        </Section>
      </xsl:if>

      <xsl:if test="tpf:FindingsRiskOrCon" >
        <Section>
          <xsl:attribute name="Name">
            <xsl:text>Cautions</xsl:text>
          </xsl:attribute>
          <Title>Cautions</Title>
          <Comment>
            <xsl:attribute name="Type">
              <xsl:text>Intro</xsl:text>
            </xsl:attribute>
            <Text>
              <xsl:text>Some medical conditions, medications, and hereditary factors can interfere with treatment or cause unwanted side effects. The following are reasons to be cautious.</xsl:text>
            </Text>
          </Comment>
          <!-- List Cons -->
          <xsl:apply-templates select="tpf:FindingsRiskOrCon" />
        </Section>
      </xsl:if>

      <xsl:if test="tpf:PlanOptions">
        <Section>
          <xsl:attribute name="Name">
            <xsl:text>FurtherInfo</xsl:text>
          </xsl:attribute>
          <Title>Further Information</Title>
          <!-- List Plan Options -->
          <xsl:apply-templates select="tpf:PlanOptions" />
        </Section>
      </xsl:if>

      <xsl:if test="tpf:LitCitList" >
        <Section>
          <xsl:attribute name="Name">
            <xsl:text>Sources</xsl:text>
          </xsl:attribute>
          <Title>Sources</Title>
          <Comment>
            <xsl:attribute name="Type">
              <xsl:text>Intro</xsl:text>
            </xsl:attribute>
            <Text>
              <xsl:text>Details about this information come from the following medical texts or medical journal articles.</xsl:text>
            </Text>
          </Comment>
          <xsl:apply-templates select="tpf:LitCitList" />
        </Section>
      </xsl:if>

    </Guidance>
  </xsl:template>

  <!--
   ///////////////////////////////////////////////////////////////////////////
   // 'CmtInfo' elements:  These are containers for sets of 'Text' and
   // 'LitCitList' elements. 
   ///////////////////////////////////////////////////////////////////////////
   -->
  <xsl:template match="tpf:CmtInfo">
    <Comment>
      <xsl:attribute name="Type">
        <xsl:text>Content</xsl:text>
      </xsl:attribute>
      <Text>
        <xsl:value-of select="tpf:Text" />
      </Text>
      <xsl:apply-templates select="tpf:LitCitList" mode="FootnoteRefs" />
    </Comment>
  </xsl:template>

  <!--
   ///////////////////////////////////////////////////////////////////////////
   // 'CmtList' elements:  These are containers for sets of 'CmtTitle',
   //  "CmtInfo" and 'LitCitList' elements. 
   ///////////////////////////////////////////////////////////////////////////
   -->
  <xsl:template match="tpf:CmtList" >
      <xsl:apply-templates select="tpf:CmtTitle|tpf:CmtInfo" />
  </xsl:template>

  <!--
   ///////////////////////////////////////////////////////////////////////////
   // 'CmtTitle' elements:  These are containers for a comment title.
   ///////////////////////////////////////////////////////////////////////////
   -->
  <xsl:template match="tpf:CmtTitle">
    <CmtTitle>
      <xsl:value-of select="." />
    </CmtTitle>
  </xsl:template>

  <!--
   ///////////////////////////////////////////////////////////////////////////
   // Elements:  tpf:FindingsEvidOrPro
   //
   // These are containers for lists of potential patient Findings associated
   // with the parent Guidance Option (the parent 'Popt').
   ///////////////////////////////////////////////////////////////////////////
   -->

  <xsl:template match="tpf:FindingsEvidOrPro">
    <xsl:param name="DDFinding" />
    <FindingList>
      <xsl:if test="$DDFinding!='' and $DDFinding!='None'">
        <Finding>
          <xsl:attribute name="Type">
            <xsl:text>Evid</xsl:text>
          </xsl:attribute>
          <Text>
            <xsl:value-of select="$DDFinding" />
          </Text>
        </Finding>
      </xsl:if>
      <xsl:apply-templates select="tpf:FndInfo" />
    </FindingList>
  </xsl:template>

  <!--
   ///////////////////////////////////////////////////////////////////////////
   // Elements:  tpf:FindingsRiskOrCon
   //
   // These are containers for lists of risk factor patient Findings associated
   // associated with the parent Guidance Option (the parent 'Popt').
   ///////////////////////////////////////////////////////////////////////////
   -->

  <xsl:template match="tpf:FindingsRiskOrCon">
    <FindingList>
      <xsl:apply-templates select="tpf:FndInfo" mode="Con"/>
    </FindingList>
  </xsl:template>

  <!--
   //////////////////////////////////////////////////////////////////////////
   // Elements:  'FndInfo'
   //
   // Contains the name (in a 'Text' element) of a potential patient Finding
   // associated with a Guidance Option, along with a list of Comments and
   // Literature Citations (in a 'LitCitList'). The Literature Citations
   // support the relationship of this particular Finding to its parent
   // Guidance Option.
   //////////////////////////////////////////////////////////////////////////
   -->
  <xsl:template match="tpf:FndInfo">
    <Finding>
      <xsl:attribute name="Type">
        <xsl:text>Evid</xsl:text>
      </xsl:attribute>
      <Text>
        <xsl:value-of select="tpf:Text" />
      </Text>
      <xsl:apply-templates select="tpf:LitCitList" mode="FootnoteRefs" />
      <xsl:apply-templates select="tpf:CmtList" />
    </Finding>
  </xsl:template>

  <!--
   //////////////////////////////////////////////////////////////////////////
   // Elements:  'FndInfo'
   // Mode:      'Con'
   // Contains the name (in a 'Text' element) of a potential patient Finding
   // associated with a Guidance Option, along with a list of Comments and
   // Literature Citations (in a 'LitCitList'). The Literature Citations
   // support the relationship of this particular Finding to its parent
   // Guidance Option.
   //////////////////////////////////////////////////////////////////////////
   -->
  <xsl:template match="tpf:FndInfo" mode="Con">
    <Finding>
      <xsl:attribute name="Type">
        <xsl:text>Con</xsl:text>
      </xsl:attribute>
      <Text>
        <xsl:value-of select="tpf:Text" />
      </Text>
      <xsl:apply-templates select="tpf:LitCitList" mode="FootnoteRefs" />
      <xsl:apply-templates select="tpf:CmtList" />
    </Finding>
  </xsl:template>

  <!--
   ////////////////////////////////////////////////////////////////////////////
   // Elements:  'LitCitList'
   //
   // A list of medical Literature Citations ('LitCit' elements) which support
   // the content of the parent element of the 'LitCitList'.
   ////////////////////////////////////////////////////////////////////////////
   -->
  <xsl:template match="tpf:LitCitList">
    <SourceList>
      <xsl:apply-templates select="tpf:LitCit">
        <xsl:sort select="@Author" order="ascending" />
      </xsl:apply-templates>
    </SourceList>
  </xsl:template>

  <!--
   //////////////////////////////////////////////////////////////////////
   // Elements:  'PlanOptCat'
   //
   // Provides a categorization of options for use in planning a response
   // to a potential diagnosis - a Guidance Option of type "Dx". These
   // options are contained in 'PlanOptInfo' elements.
   //////////////////////////////////////////////////////////////////////
   -->
  <xsl:template match="tpf:PlanOptCat">
    <xsl:apply-templates select="tpf:PlanOptInfo" />
  </xsl:template>

  <!--
   ///////////////////////////////////////////////////////////////////////
   // Elements:  PlanOptions
   //
   // These are containers for lists of potential Plan Options associated
   // with the parent Guidance Option (the parent 'Popt').
   ///////////////////////////////////////////////////////////////////////
   -->
  <xsl:template match="tpf:PlanOptions">
    <PlanOptionList>
      <xsl:apply-templates select="tpf:PlanOptCat" />
    </PlanOptionList>
  </xsl:template>

  <!--
   //////////////////////////////////////////////////////////////////////////
   // Elements:  'PlanOptInfo'
   //
   // Contains the name (in a 'Text' element) of a potential option for
   // pursuing (testing for) a Guidance Option, along with a list of Comments
   // and Literature Citations (in a 'LitCitList'). The Literature Citations
   // support the relationship of this particular Plan Option to its parent
   // Guidance Option.
   //////////////////////////////////////////////////////////////////////////
   -->
  <xsl:template match="tpf:PlanOptInfo">
    <PlanOption>
      <xsl:attribute name="Name">
        <xsl:value-of select="../@Name" />
      </xsl:attribute>
      <Text>
        <xsl:value-of select="tpf:Text" />
      </Text>
      <xsl:apply-templates select="tpf:LitCitList" mode="FootnoteRefs" />
      <xsl:apply-templates select="tpf:CmtList" />
    </PlanOption>
  </xsl:template>

  <!--
   ////////////////////////////////////////////////////////////////////////////
   // Elements:  'LitCitList'
   //
   // A list of medical Literature Citations ('LitCit' elements) which support
   // the content of the parent element of the 'LitCitList'.
   ////////////////////////////////////////////////////////////////////////////
   -->
  <xsl:template match="tpf:LitCitList">
    <SourceList>
      <xsl:apply-templates select="tpf:LitCit">
        <xsl:sort select="@Author" order="ascending" />
      </xsl:apply-templates>
    </SourceList>
  </xsl:template>

</xsl:stylesheet>
