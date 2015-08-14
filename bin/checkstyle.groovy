#!/usr/bin/env groovy
import groovy.io.FileType
import groovy.json.JsonSlurper
import groovy.json.JsonOutput
import groovy.util.FileNameFinder
import groovy.util.XmlParser 


def appContext = setupContext(args)
assert appContext


def configJson = new JsonSlurper().parse(new File(appContext.configFile), "UTF-8")


def codeFolder = new File(appContext.codeFolder)
assert codeFolder.exists()


def excludeString = ".codeclimate.yml " + configJson.exclude_paths.join(" ") 


def scriptDir = getClass().protectionDomain.codeSource.location.path.replace("/${this.class.name}.groovy","")
def checkerDefinitionFromConfig = configJson.config
def checkerDefinitionFile = null
if (configJson.config?.trim()) {
	checkerDefinitionFile = new File(codeFolder, configJson.config)
} else {
    checkerDefinitionFile = new File(scriptDir.replace('/bin','/config'), 'google_checkstyle.xml')
}
assert checkerDefinitionFile.exists() && checkerDefinitionFile.isFile()


def fileToAnalyse = new FileNameFinder().getFileNames(appContext.codeFolder,'**/*', excludeString)

fileToAnalyse.each {
	def sout = new StringBuffer()
	def serr = new StringBuffer()        
	
	def outputFilePath = "/tmp/${java.util.UUID.randomUUID()}.xml"

	def analysis = "java -jar ${scriptDir}/checkstyle.jar -c ${checkerDefinitionFile.path} ${it} -f xml -o ${outputFilePath}".execute()
	analysis.consumeProcessOutput(sout, serr)
	analysis.waitFor()
	if (analysis.exitValue() !=0 ) {
		System.err << serr.toString()
	}

	def outputFile = new File(outputFilePath)
	def analysisResult = new XmlParser().parseText(outputFile.text)

	analysisResult.file?.error.findAll { errTag ->
		def defect = JsonOutput.toJson([
			type: "issue",
		       	check_name: errTag.@source,
		       	description: errTag.@message,
		       	categories: [ "Style" ],
		       	location: [
		       		path: it.replace(codeFolder.path, ''),
		       		positions: [
		       			begin: [
		       				line: errTag.@line,
		       				column: errTag.@column ? errTag.@column : 1
		       			],
		       			end: errTag.@line
		       		] 
		       	]
		])
		println "${defect}\0"
	}
	outputFile.delete()
}


def setupContext(cmdArgs) { 
	def cli = new CliBuilder(usage:"${this.class.name}")
	cli._(longOpt: "configFile", required: true, args: 1, "Path to configuration json file")
	cli._(longOpt: "codeFolder", required: true, args: 1, "Path to code folder")
	cli.parse(cmdArgs)
}

