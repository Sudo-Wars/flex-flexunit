package org.flexunit.ant.tasks.configuration;

import java.io.File;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Arrays;
import java.util.List;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.FileSet;
import org.flexunit.ant.LoggingUtil;
import org.flexunit.ant.tasks.types.LoadConfig;

public class TaskConfiguration
{
   private final String DEFAULT_WORKING_PATH = ".";
   private final String DEFAULT_REPORT_PATH = ".";
   private final List<String> VALID_PLAYERS = Arrays.asList(new String[]{"flash", "air"});
   
   private String player = "flash";
   private File reportDir = null;
   private File workingDir = null;
   private boolean verbose = false;
   private File flexHome = null;
   
   private Project project;
   private CompilationConfiguration compilationConfiguration;
   private TestRunConfiguration testRunConfiguration;
   
   public TaskConfiguration(Project project)
   {
      this.project = project;
      this.compilationConfiguration = new CompilationConfiguration();
      this.testRunConfiguration = new TestRunConfiguration();
      
      if(project.getProperty("FLEX_HOME") != null)
      {
         this.flexHome = new File(project.getProperty("FLEX_HOME"));
      }
   }
   
   //Used to verify that a string is also a properly formatted URL
   //When determining if the passed 'swf' property value is remote or local this is crucial.
   protected boolean isValidURI(String uriStr) {
	    try {
	      URI uri = new URI(uriStr);
	      return true;
	    }
	    catch (URISyntaxException e) {
	        return false;
	    }
	}
   
   public CompilationConfiguration getCompilationConfiguration()
   {
      return compilationConfiguration;
   }
   
   public TestRunConfiguration getTestRunConfiguration()
   {
      return testRunConfiguration;
   }

   public void setCommand(String commandPath)
   {
      testRunConfiguration.setCommand(project.resolveFile(commandPath));
   }
   
   public void setDisplay(int display)
   {
      testRunConfiguration.setDisplay(display);
   }

   public void setFailOnTestFailure(boolean failOnTestFailure)
   {
      testRunConfiguration.setFailOnTestFailure(failOnTestFailure);
   }

   public void setFailureProperty(String failureProperty)
   {
      testRunConfiguration.setFailureProperty(failureProperty);
   }
   
   public void addSource(FileSet fileset)
   {
      fileset.setProject(project);
      compilationConfiguration.addSource(fileset);
   }
   
   public void addTestSource(FileSet fileset)
   {
      fileset.setProject(project);
      compilationConfiguration.addTestSource(fileset);
   }
   
   public void addLibrary(FileSet fileset)
   {
      fileset.setProject(project);
      compilationConfiguration.addLibrary(fileset);
   }
   
   public void setHeadless(boolean headless)
   {
      testRunConfiguration.setHeadless(headless);
   }

   public void setLocalTrusted(boolean isLocalTrusted)
   {
      testRunConfiguration.setLocalTrusted(isLocalTrusted);
   }

   public void setPlayer(String player)
   {
      this.player = player;
   }

   public void setPort(int port)
   {
      testRunConfiguration.setPort(port);
   }

   public void setReportDir(String reportDirPath)
   {
      this.reportDir = project.resolveFile(reportDirPath);
   }

   public void setServerBufferSize(int serverBufferSize)
   {
      testRunConfiguration.setServerBufferSize(serverBufferSize);
   }

   public void setSocketTimeout(int socketTimeout)
   {
      testRunConfiguration.setSocketTimeout(socketTimeout);
   }

   public void setSwf(String swf)
   {
	   //match the swf URL to see if it's a remote location, if so, set the url instead of swf.
		if( isValidURI( swf ) ) {
			testRunConfiguration.setUrl(swf);
			LoggingUtil.log("Remote path to SWF was given, setting URL property instead of SWF");
		} else {
			testRunConfiguration.setSwf(project.resolveFile(swf));
			LoggingUtil.log("Local path to SWF was given, SWF property as usual.");
		} 
	   
   }
   
   public void setSwf(File swf)
   {
      testRunConfiguration.setSwf(swf);
   }
   
   public boolean isVerbose()
   {
      return verbose;
   }

   public void setVerbose(boolean verbose)
   {
      this.verbose = verbose;
      LoggingUtil.VERBOSE = verbose;
   }
   
   public void setWorkingDir(String workingDirPath)
   {
      this.workingDir = project.resolveFile(workingDirPath);
   }
   
   public boolean shouldCompile()
   {
      File swf = testRunConfiguration.getSwf();
      boolean noTestSources = !compilationConfiguration.getTestSources().provided();
      return !noTestSources && (swf == null || !swf.exists());
   }
   
   public void verify() throws BuildException
   {
      validateSharedProperties();
      
      if(shouldCompile())
      {
         compilationConfiguration.validate();
      }
      
      testRunConfiguration.validate();
      
      propagateSharedConfiguration();
   }

   protected void validateSharedProperties() throws BuildException
   {
      LoggingUtil.log("Validating task attributes ...");
      
      if(!VALID_PLAYERS.contains(player))
      {
         throw new BuildException("The provided 'player' property value [" + player + "] must be either of the following values: " + VALID_PLAYERS.toString() + ".");
      }
      
      File swf = testRunConfiguration.getSwf();
      boolean noTestSources = !compilationConfiguration.getTestSources().provided();
      String swfURL = testRunConfiguration.getUrl();
      
      //Check to make sure we have a valid swf, testsource or remote url before proceeding.
      //Otherwise, notify the user to fix this before continuing.
      if ((swf == null || !swf.exists()) && noTestSources && (swfURL == "" || swfURL == null) )
      {
         throw new BuildException("The provided 'swf' property value [" + (swf == null ? "" : swf.getPath()) + "] could not be found or is not a valid remote URL.");
      }
      
      if( (swfURL != null && swfURL != "") && testRunConfiguration.isLocalTrusted() ) 
      {
    	  throw new BuildException("The provided 'swf' property value points to a remote location.  Please set localTrusted = false or change the location of your swf to a local path.");
      }
      
      if(swf != null && !noTestSources)
      {
         throw new BuildException("Please specify the 'swf' property or use the 'testSource' element(s), but not both.");
      }
      
      //if we can't find the FLEX_HOME and we're using ADL or compilation
      if((flexHome == null || !flexHome.exists()) && (new String("air").equals(testRunConfiguration.getPlayer()) || shouldCompile()))
      {
         throw new BuildException("Please specify, or verify the location for, the FLEX_HOME property.  "
               + "It is required when testing with 'air' as the player or when using the 'testSource' element.  "
               + "It should point to the installation directory for a Flex SDK.");
      }
   }
   
   protected void propagateSharedConfiguration()
   {
      LoggingUtil.log("Generating default values ...");
      
      //setup player
      compilationConfiguration.setPlayer(player);
      testRunConfiguration.setPlayer(player);
      
      //set FLEX_HOME property to respective configs
      compilationConfiguration.setFlexHome(flexHome);
      testRunConfiguration.setFlexHome(flexHome);
      
      //create working directory if needed
      if (workingDir == null || !workingDir.exists())
      {
         workingDir = project.resolveFile(DEFAULT_WORKING_PATH);
         LoggingUtil.log("Using default working dir [" + workingDir.getAbsolutePath() + "]");
      }

      //create directory just to be sure it exists, already existing dirs will not be overwritten
      workingDir.mkdirs();
      
      compilationConfiguration.setWorkingDir(workingDir);
      
      //create report directory if needed
      if (reportDir == null || !reportDir.exists())
      {
         reportDir = project.resolveFile(DEFAULT_REPORT_PATH);
         LoggingUtil.log("Using default reporting dir [" + reportDir.getAbsolutePath() + "]");
      }

      //create directory just to be sure it exists, already existing dirs will not be overwritten
      reportDir.mkdir();
      
      testRunConfiguration.setReportDir(reportDir);
   }
   
   public void setDebug(boolean value)
   {
       compilationConfiguration.setDebug(value);
   }

   public void setLoadConfig(LoadConfig loadconfig)
   {
       compilationConfiguration.setLoadConfig(loadconfig);
   }

}