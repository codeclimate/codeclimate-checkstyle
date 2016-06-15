#!/usr/bin/env groovy
import groovy.io.FileType
import groovy.json.JsonSlurper
import groovy.json.JsonOutput
import groovy.util.FileNameFinder
import groovy.util.XmlParser

def appContext = setupContext(args)
def parsedConfig = new JsonSlurper().parse(new File(appContext.configFile), "UTF-8")
def includePaths = parsedConfig.include_paths?.join(" ")
def codeFolder = new File(appContext.codeFolder)

def filesToAnalyse = new FileNameFinder().getFileNames(appContext.codeFolder, includePaths)

def i = filesToAnalyse.iterator()
while(i.hasNext()) {
    string = i.next()
    if( !string.endsWith(".java")) {
        i.remove()
    }
}

filesToAnalyse = filesToAnalyse.join(" ")
if (filesToAnalyse.isEmpty()) {
	System.exit(0)
}

def ruleSetPath
if ( parsedConfig.config && (new File(parsedConfig.config).exists()) ) {
  ruleSetPath = "/code/${parsedConfig.config}"
} else {
  ruleSetPath = "/usr/src/app/config/codeclimate_checkstyle.xml"
}

def sout = new StringBuffer()
def serr = new StringBuffer()

def analysis = "java -jar /usr/src/app/bin/checkstyle.jar -c ${ruleSetPath} -f xml ${filesToAnalyse}".execute()

analysis.consumeProcessOutput(sout, serr)
analysis.waitFor()

if (analysis.exitValue() !=0 ) {
	System.err << serr.toString()
	System.exit(1)
}

analysis.waitForProcessOutput()

if (sout.toString().isEmpty()) {
	System.exit(1)
}

def outputLines = sout.toString().tokenize("\n")
def xmlText = ""

if(outputLines[-1] != "</checkstyle>") {
	xmlText = outputLines[0..-2].join("\n")
} else {
	xmlText = outputLines.join("\n")
}

def analysisResult

try {
	analysisResult = new XmlParser().parseText(xmlText)
} catch (org.xml.sax.SAXParseException e) {
	System.err << e
	System.err << xmlText
	System.exit(1)
}

analysisResult.file.findAll { file ->
	file.error.findAll { errTag ->
		def defect = JsonOutput.toJson([
			type: "issue",
		       	check_name: cleanupCheckName(errTag.@source),
		       	description: errTag.@message,
		       	categories: [ "Style" ],
		       	location: [
		       		path: file.@name.replaceAll("/code/",""),
		       		positions: [
		       			begin: [
		       				line: errTag.@line.toInteger(),
		       				column: errTag.@column ? errTag.@column.toInteger() : 1,
		       			],
		       			end: [
		       				line: errTag.@line.toInteger(),
		       				column: errTag.@column ? errTag.@column.toInteger() : 1,
		       			]
		       		]
		       ],
					 remediation_points: 150000,
		])
		println "${defect}\0"
	}
}

System.exit(0)

def setupContext(cmdArgs) {
	def cli = new CliBuilder(usage:"${this.class.name}")
	cli._(longOpt: "configFile", required: true, args: 1, "Path to configuration json file")
	cli._(longOpt: "codeFolder", required: true, args: 1, "Path to code folder")
	cli.parse(cmdArgs)
}

def cleanupCheckName(checkName) {
	checkName.tokenize(".")[-1].split("(?=[A-Z])").join(" ")
}
