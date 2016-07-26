import os
import sys
import getopt
import shutil

def folderCreate(folder):

    from os.path import expanduser
    
    home = expanduser("~") 
    valid = ["yes","y","ye"]

    if os.path.isdir(home+'/'+folder):
        print 'folder found'
        while True:
            sys.stdout.write("Folder found. Do you want to overwrite? [Y/n]")
            choice = raw_input().lower()
            if choice in valid:
                break
            else:
                sys.stdout.write("Exiting\n")
                return 1
    print 'got to overwite file location'

#create folders
    if not os.path.exists(home+'/'+folder+'/module'):
        os.makedirs(home+'/'+folder+'/module')
    if not os.path.exists(home+'/'+folder+'/src'):
        os.makedirs(home+'/'+folder+'/src')
    if not os.path.exists(home+'/'+folder+'/src/org'):
        os.makedirs(home+'/'+folder+'/src/org')
    if not os.path.exists(home+'/'+folder+'/src/gui-kepler'):
        os.makedirs(home+'/'+folder+'/src/gui-kepler')
    if not os.path.exists(home+'/'+folder+'/src/org/uq'):
        os.makedirs(home+'/'+folder+'/src/org/uq')
    if not os.path.exists(home+'/'+folder+'/module/resources'):
        os.makedirs(home+'/'+folder+'/module/resources')
    if not os.path.exists(home+'/'+folder+'/module/resources/kar'):
        os.makedirs(home+'/'+folder+'/module/resources/kar')
    if not os.path.exists(home+'/'+folder+'/module/resources/kar/actors'):
        os.makedirs(home+'/'+folder+'/module/resources/kar/actors')
    if not os.path.exists(home+'/'+folder+'/module/module-info'):
        os.makedirs(home+'/'+folder+'/module/module-info')
        module = open(home+'/'+folder+'/module/module-info/modules.txt','w')
        module.write('*kepler-2.2.^')
        module.close()






    return 0

def gradleBuild(folder):

    from os.path import expanduser
    home = expanduser("~") 

#settings = rootProject.name = 'PRojectNAME'/n
    settings = open(home+'/'+folder+'/settings.gradle','w')
    settings.write('rootProject.name = \''+folder+'\'\n')
#copy gradle build file to project folder
    if not os.path.isfile(home+'/'+folder+'/build.gradle'):
        shutil.copyfile('build.gradle',home+'/'+folder+'/build.gradle')
        print 'copying gradle build file'
    return 0

def ontologyCreate(folder):

    from os.path import expanduser
    home = expanduser("~") 

    ontologyFile = open(home+'/'+folder+'/src/gui-kepler/ontology_catalog.xml.addon','w')
    ontologyTemplate = open('ontology_template.xml.addon','r')
    ontLines = ontologyTemplate.readlines()
    for i in ontLines:
        i = i.replace('ONTOLOGYNAME',folder)
        ontologyFile.write(i)
    ontologyFile.close()
    ontologyTemplate.close()

    owlFile = open(home+'/'+folder+'/src/gui-kepler/'+folder+'-project.owl','w')
    owlTemplate = open('template-project.owl','r')
    owlLines = owlTemplate.readlines()
    for i in owlLines:
        i = i.replace('PROJECTNAME',folder)
        owlFile.write(i)
    owlFile.close()
    owlTemplate.close()
    
    return 0

def xmlCreate(actorName,folder):

    from os.path import expanduser
    home = expanduser("~") 

    xmlFile = actorName
    xmlPath = home+'/'+folder+'/module/resources/kar/actors/' 

    if os.path.isfile(xmlPath+xmlFile+'.xml'):
        print 'xml file found'
        return 0
   
    if os.path.isfile(xmlPath+'actors.txt'):
        actors = open(xmlPath+'actors.txt','r+')
        actorLines = actors.readline()
        actorCount = int(actorLines)
    else:
        actors = open(xmlPath+'actors.txt','w')
        actors.write("1")
        actorCount = 1

    print 'Actor Count: '+str(actorCount)
    try:
        f = open('Template.xml','r')
    except IOError:
        print 'Error: Template.xml file missing.'
        return 0
        
    lines = f.readlines()
    writeto = open(xmlPath+xmlFile+'.xml','w')
    for i in lines:
        i = i.replace('NAMEHERE',xmlFile)
        i = i.replace('ACTORNO',str(actorCount))
        writeto.write(i)
    writeto.close()
    f.close()

    if not os.path.isfile(xmlPath+'MANIFEST.MF'):
        print 'manifest file creating'
        createManifest = open(xmlPath+'MANIFEST.MF','w')
        with open('ManifestOriginal.MF','r') as manOrig:
            content = manOrig.read()
            content = content.replace('\r','')
            createManifest.write(content)
        createManifest.close()
        manOrig.close()


    manifestFile = open(xmlPath+'MANIFEST.MF','a')
    manifestTemplate = open('ManifestTemplate.txt','r')
    manTempRead = manifestTemplate.readlines()
    
    for i in manTempRead:
        i = i.replace('NAMEHERE',xmlFile)
        i = i.replace('ACTORNO',str(actorCount))
        i = i.replace('\r','')
        manifestFile.write(i)

    manifestFile.close()
    manifestTemplate.close()

    actors.seek(0)
    actors.write(str(actorCount+1))
    actors.close()
    
    return 0

def main(argv):

    from os.path import expanduser
    home = expanduser("~") 

    if len(argv) != 3:
        print 'Usage: rconvert.py folderName RFileName'
        return 0
   # print str(argv[1])+" "+str(argv[2])

    folderName = argv[1] #'testing'
    fileName = argv[2]#'test.txt'

#R CODE FILE LOCATION HERE
#    f = open(argv[1],'r')
    try:
        f = open(fileName,'r')
    except IOError:
        print 'Error: Missing R Code txt file.'
        return 1


    if folderCreate(folderName):
        return 0
    
    #javaSrcLoc = './'
    javaSrcLoc = home+'/'+folderName+'/src/org/uq/' 
   # javaSrcLoc = '../nimrodok/src/org/uq/' 
    
    flag = 0
    varStart = 0
    varEnd = 0
    count = 0
    varName = []
    varIO = []
    varType = []
    lines = f.readlines()
    f.close()
    modName = lines[0]
    modName = modName[1:-2]
    print "module Name: "+modName
    for i in lines[1:]:
        count+=1
        i = i.replace("\r","")
##        print i + str(count)
        if i == "#VarEnd\n":
            varEnd = count
            print "variables end " + str(varEnd)
##        if flag == 1:

        elif i == "#VarStart\n":
            varStart = count + 1
            print "variables start " + str(varStart)
        
    for i in lines[varStart:varEnd]:
        test = i.split(",")
        varName.append(test[0][1:])
        varIO.append(test[1])
        varType.append(test[2][:-2])
    #print varName,varIO,varType
#TEMPLATE FILE LOCATION GOES HERE   
    try:
        readIn = open('HelloWorld.txt','r')
    except IOError:
        print "Error: File Template does not exist."
        return 0
#WRITE TO FILE LOCATION HERE        
    writeTo = open(javaSrcLoc+modName+'.java','w')
    readLines = readIn.readlines()
    flag = 1
    for i in readLines:
        i = i.replace("NAMEHERE",modName)
        if flag == 1:
            writeTo.write(i)
        if i == "//VarDeclaration\n":
            flag = 0
            print "found vardec start"
##            break
            for j in range(0,len(varName)):
                writeTo.write("public TypedIOPort " + varName[j]+";\n")
        if i == "//VarEndDeclaration\n":
            flag = 1
            writeTo.write(i)
        if i == "//StartRCode\n":
            flag = 0
            print 'found startrcode'
            for j in lines:
                j = j.replace("\"","\\\"")
                writeTo.write("+\""+j.rstrip()+"\\n\""+"\n")
        if i == "//EndRCode\n":
            flag = 1
            writeTo.write(i)

        if i == "//VarStart\n":
            flag = 0
            print 'found varstart'
            for j in range(0,len(varName)):
                if varIO[j].lower() == "input":
                    IOStr = "true, false);"
                else:
                    IOStr = "false, true);"
                writeTo.write(varName[j]+" = new TypedIOPort(this,\""+varName[j]+"\", "+IOStr+"\n")
                writeTo.write(varName[j]+".setTypeEquals(BaseType."+varType[j]+");\n")

        if i == "//VarEnd\n":
            flag = 1
            writeTo.write(i)

    xmlCreate(modName,folderName)
    ontologyCreate(folderName)
    gradleBuild(folderName)
################################################################################
if __name__ == "__main__":
    main(sys.argv)
