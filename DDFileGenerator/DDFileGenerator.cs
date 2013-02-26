/******************************************************************************
 ****************              DDFileGenerator.cs              ****************
 ****************     Copyright 1982-2012, PKC Corporation     ****************
 ******************************************************************************

 Description:
   Generates Deep Dive XML files from TPF files.

 *****************************************************************************/

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;
using System.Xml.XPath;
using System.Xml.Xsl;


namespace DDFileGenerator
{
  /**
   ******************************************************************************
   *****     DDFileGenerator     ************************************************
   ******************************************************************************
  
    <summary>
      Creates Deep Dive XML files from TPF files. The files are created by an 
      XSL transform 
    </summary>
  
   *****************************************************************************/

  class DDFileGenerator
  {
    const string        strDDDir      = "\\DeepDive";

    static bool         m_bAll        = false;
    static string       m_strTpfDir;
    static List<String> m_lDDId;
    static List<String> m_lDDName;
    static List<String> m_lTopicName;
    static List<String> m_lGOName;

    static void Main(string[] args)
    {
      // Get TPF directory path.
      if (args.Length > 0)
      {
        m_strTpfDir = args[0];
      }

      // Verify we have valid TPF directory
      if ((args.Length == 0) || (!Directory.Exists (m_strTpfDir)))
      {
        System.Console.WriteLine("Please enter the TPF path.");
        return;
      }

      // Check for ALL flag.
      if ((args.Length > 1) && (args[1] == "ALL"))
      {
        m_bAll = true;
      }

      // Generate path and name for output file.
      string strXmlDir = m_strTpfDir + strDDDir;

      if (!Directory.Exists (strXmlDir))
        Directory.CreateDirectory (strXmlDir);

      // Create lists for Index information.
      m_lDDId       = new List<string>();
      m_lDDName     = new List<string>();
      m_lTopicName  = new List<string>();
      m_lGOName     = new List<string>();

      CreateDDFiles ();
    }

    /**
     ******************************************************************************
     *****     CreateDDFiles     **************************************************
     ******************************************************************************
    
      <summary>
        Creates the DeepDive files.
      </summary>
    
     *****************************************************************************/

    private static void CreateDDFiles()
    {
       // Create the XsltSettings object with document function enabled.
      XsltSettings settings = new XsltSettings(true,false);

      // Create an XmlUrlResolver with default credentials.
      XmlUrlResolver resolver = new XmlUrlResolver();
      resolver.Credentials = System.Net.CredentialCache.DefaultCredentials;

      // Create the reader.
      XmlReaderSettings readerSettings = new XmlReaderSettings();
      readerSettings.XmlResolver = resolver;

      // Load the transform.
      XslCompiledTransform xslt = new XslCompiledTransform (false);
      xslt.Load ("..\\..\\XSLT\\TPFtoDDTransform.xsl",settings,resolver);

      var xmlSettings = new XmlWriterSettings();
      xmlSettings.CloseOutput = true;
      xmlSettings.Indent = true;
      xmlSettings.NewLineChars = "\r\n";
     
      // Get list of TPF files.
      var files = Directory.EnumerateFiles (m_strTpfDir,"*.xml");

      foreach (string file in files)
      {
        System.Console.WriteLine("Processing file " + file + " ...");

        if (m_bAll)
        {
          // Put all GOs into one file.
          string strOutputFile = CreateOutputFilename (file);

          // Transform the file 
          using (XmlWriter writer = XmlWriter.Create(strOutputFile,xmlSettings))
          {
            xslt.Transform (file,writer);
          }
        }
        else
        {
          // Break into files by entity number.
          IEnumerable<string> entities = GetEntityNumbers (file);

          foreach (string strEntity in entities)
          {
            // Create the XsltArgumentList.
            XsltArgumentList xslArg = new XsltArgumentList();
            xslArg.AddParam ("EntityNumber","",strEntity);
 
            string strOutputFile = CreateOutputFilename (file,strEntity);
            // Transform the file 
            using (XmlWriter writer = XmlWriter.Create(strOutputFile,xmlSettings))
            {
              xslt.Transform (file,xslArg,writer);
            }

//            SaveIndexInfo (strOutputFile);
          }
          System.Console.WriteLine("Completed.");
        }
      }
   }

    /**
     ******************************************************************************
     *****     CreateOutputFilename     *******************************************
     ******************************************************************************
    
      <summary>
        Creates an output filename.
      </summary>
    
      <param name="strInputFile">
        The input file.
      </param>
    
      <returns>
        The fully qualified output filename.
      </returns>
    
     *****************************************************************************/

    public static string CreateOutputFilename (string strInputFile)
    {
      string strPath     = Path.GetDirectoryName(strInputFile) + strDDDir + "\\";
      string strTopicNum = Path.GetFileNameWithoutExtension(strInputFile);
      strTopicNum = strTopicNum.Replace("TPF_", "");

      string strOutputFile = strPath + "DD" + strTopicNum + ".xml";

      return strOutputFile;
    }

    /**
     ******************************************************************************
     *****     CreateOutputFilename     *******************************************
     ******************************************************************************
    
      <summary>
        Creates an output filename.
      </summary>
    
      <param name="strInputFile">
        The input file.
      </param>
      <param name="strEntity">
        The entity.
      </param>
    
      <returns>
        The fully qualified output filename.
      </returns>
    
     *****************************************************************************/

    public static string CreateOutputFilename (string strInputFile,string strEntity)
    {
      string strPath     = Path.GetDirectoryName(strInputFile) + strDDDir + "\\";
      string strTopicNum = Path.GetFileNameWithoutExtension(strInputFile);
      strTopicNum = strTopicNum.Replace("TPF_", "");

      string strOutputFile = strPath + strTopicNum + "-" + strEntity + ".xml";

      return strOutputFile;
    }

    /**
     ******************************************************************************
     *****     GetEntityNumbers     ***********************************************
     ******************************************************************************
    
      <summary>
        Gets a list of entity numbers from the TPF file.
      </summary>
    
      <param name="strTpfFile">
        The tpf file.
      </param>
    
      <returns>
        The entity numbers.
      </returns>
    
     *****************************************************************************/

    public static List<string> GetEntityNumbers (string strTpfFile)
    {
      // Create document and navigator.
      XPathDocument  xPathDoc    = new XPathDocument (strTpfFile);
      XPathNavigator xPathNavigator = xPathDoc.CreateNavigator ();

      // Setup namespace resolver.
      string strRootNamespace = GetRootNamespace (strTpfFile);
      XmlNamespaceManager manager = new XmlNamespaceManager(xPathNavigator.NameTable);
      manager.AddNamespace ("tpf", strRootNamespace);

      // Setup query and do selection.
      string strXPathExpr = "/tpf:PkcTpfDoc/tpf:Advisor/tpf:PoptCat/tpf:Popt";
      XPathNodeIterator nodeIterator = xPathNavigator.Select (strXPathExpr,manager);

      List<string> entities = new List<string>();

      // Get the entity number attribute from each node and save in list.
      foreach (XPathNavigator node in nodeIterator)
      {
        string strEntity = node.GetAttribute ("EntNo","");
        entities.Add (strEntity);
      }

      return entities;
    }

    /**
     ******************************************************************************
     *****     GetRootNamespace     ***********************************************
     ******************************************************************************
    
      <summary>
        Gets the root namespace from the file.
      </summary>
    
      <param name="strPath">
        Full pathname of the file.
      </param>
    
      <returns>
        The root namespace.
      </returns>
    
     *****************************************************************************/

    private static string GetRootNamespace (string strPath)
    {
      // Create document and navigator.
      XPathDocument xPathDoc = new XPathDocument (strPath);
      XPathNavigator xPathNavigator = xPathDoc.CreateNavigator ();

      xPathNavigator.MoveToFollowing (XPathNodeType.Element);

      // Get list of namespaces.
      IDictionary<string,string> list =
        xPathNavigator.GetNamespacesInScope (XmlNamespaceScope.Local);

      // return root namespace.
      return list.Values.ElementAt (0);
    }

    ///**
    // ******************************************************************************
    // *****     SaveIndexInfo     **************************************************
    // ******************************************************************************
    
    //  <summary>
    //    Saves an indexing information for one file.
    //  </summary>
    
    //  <param name="strPath">
    //    Full pathname of the file.
    //  </param>

    //  This method is under developement. It is neither correct or complete!!!
    //  It was intended to extract the information needed for search indexes.
    //  See FogBugz #4771.
    
    // *****************************************************************************/

    //private static void SaveIndexInfo (string strPath)
    //{
    //  // Create document and navigator.
    //  XPathDocument  xPathDoc    = new XPathDocument (strPath);
    //  XPathNavigator xPathNavigator = xPathDoc.CreateNavigator ();

    //  xPathNavigator.MoveToFollowing (XPathNodeType.Element);

    //  string strTopicName = xPathNavigator.GetAttribute ("Name","");
    //  m_lTopicName.Add (strTopicName);

    //  xPathNavigator.MoveToFollowing (XPathNodeType.Element);

    //  string strGOName = xPathNavigator.GetAttribute ("Name","");
    //  m_lGOName.Add (strGOName);

    //  // Setup namespace resolver.
    //  string strRootNamespace = GetRootNamespace (strPath);
    //  XmlNamespaceManager manager = new XmlNamespaceManager(xPathNavigator.NameTable);
    //  manager.AddNamespace ("dd", strRootNamespace);

    //  // Setup query and do selection.
    //  string strXPathExpr = "/dd:PkcGuidanceSet/dd:Guidance/dd:Section";
    //  XPathNodeIterator nodeIterator = xPathNavigator.Select (strXPathExpr,manager);

    //  while (nodeIterator.MoveNext())
    //  {
    //    if (nodeIterator.Current.GetAttribute("Name",string.Empty) == "Summary")
    //    {
    //      nodeIterator.Current.MoveToChild ("Title", string.Empty);
    //      m_lDDName.Add (nodeIterator.Current.Value);
    //      break;
    //    }
    //  }
    //}
    // 
  }
}
