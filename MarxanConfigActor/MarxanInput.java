package org.monash.nimrod;

import java.io.IOException;
import java.io.Writer;
import java.util.Set;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.nio.file.*;
import org.apache.commons.io.FileUtils;

import ptolemy.actor.TypedIOPort;
import ptolemy.actor.TypedAtomicActor;
import ptolemy.actor.lib.LimitedFiringSource;
import ptolemy.actor.parameters.PortParameter;
import ptolemy.data.BooleanToken;
import ptolemy.data.StringToken;
import ptolemy.data.expr.FileParameter;
import ptolemy.data.expr.Parameter;
import ptolemy.data.type.BaseType;
import ptolemy.graph.Inequality;
import ptolemy.kernel.CompositeEntity;
import ptolemy.kernel.util.IllegalActionException;
import ptolemy.kernel.util.NameDuplicationException;

public class MarxanInput extends TypedAtomicActor {
	

	
	public MarxanInput(CompositeEntity container, String name) throws NameDuplicationException, IllegalActionException {
		super(container, name);
		
		InputFilesDir = new TypedIOPort(this, "InputFilesDir", true, false);
		InputFilesDir.setTypeEquals(BaseType.STRING);
		OutputFilesDir = new TypedIOPort(this, "OutputFilesDir", true, false);
		OutputFilesDir.setTypeEquals(BaseType.STRING);
		
		InputParam = new PortParameter(this, "InputParam", new StringToken(
                textOne));
        // Make command be a StringParameter (no surrounding double quotes).
		InputParam.setStringMode(true);
        new Parameter(InputParam.getPort(), "_showName", BooleanToken.TRUE);
        
        SaveFileParam = new PortParameter(this, "SaveFileParam", new StringToken(
                textTwo));
        // Make command be a StringParameter (no surrounding double quotes).
        SaveFileParam.setStringMode(true);
        new Parameter(SaveFileParam.getPort(), "_showName", BooleanToken.TRUE);
		
        ProgramControlParam = new PortParameter(this, "ProgramControlParam", new StringToken(
                textThree));
        // Make command be a StringParameter (no surrounding double quotes).
        ProgramControlParam.setStringMode(true);
        new Parameter(ProgramControlParam.getPort(), "_showName", BooleanToken.TRUE);
        
        PuLayerFile = new TypedIOPort(this,"PuLayerFile",true,false);
        PuLayerFile.setTypeEquals(BaseType.STRING);


		MarxanFile = new TypedIOPort(this, "MarxanFile", true, false);
		MarxanFile.setTypeEquals(BaseType.STRING);

        NewMarxanLocation = new TypedIOPort(this, "NewMarxanLocation", true, false);
        NewMarxanLocation.setTypeEquals(BaseType.STRING);
        
        MarxanLoc = new TypedIOPort(this, "MarxanLoc", false, true);
		MarxanLoc.setTypeEquals(BaseType.STRING);
	    
	}
	// /////////////////////////////////////////////////////////////////
	// // ports and parameters ////

	/**
	 * The first input port, which contains the text to be written.
	 */
	public TypedIOPort InputFilesDir = null;
	public TypedIOPort OutputFilesDir = null;
	public TypedIOPort MarxanLoc = null;
    public TypedIOPort PuLayerFile = null;
	/**
	 * The second input port, which contains the file path and name to which to
	 * write.
	 */
	public TypedIOPort NewMarxanLocation = null;
	/**
	 * The input port, which contains the old file path and name.
	 */
	public TypedIOPort MarxanFile = null;
	public PortParameter InputParam;
	public PortParameter SaveFileParam;
	public PortParameter ProgramControlParam;
	
	@Override
	public void fire() throws IllegalActionException {
		// TODO Auto-generated method stub
		super.fire();
		InputParam.update();
		if (NewMarxanLocation.hasToken(0)) {
			
			pathdir = ((StringToken) NewMarxanLocation.get(0)).stringValue();
			inDir = ((StringToken) InputFilesDir.get(0)).stringValue();
	        outDir = ((StringToken) OutputFilesDir.get(0)).stringValue();
            fixedInput = ((StringToken) InputParam.getToken()).stringValue().replace(';','\n');
			fixedInput = fixedInput.replace("\"","");
			fixedInputTwo = ((StringToken) SaveFileParam.getToken()).stringValue().replace(';','\n');
			fixedInputTwo = fixedInputTwo.replace("\"","");
			fixedInputThree = ((StringToken) ProgramControlParam.getToken()).stringValue().replace(';','\n');
			fixedInputThree = fixedInputThree.replace("\"","");
			_text = fixedInput + inDir + fixedInputTwo+ outDir+ fixedInputThree;
			_path = pathdir + "/input.dat";
			_dir = new File(pathdir);
            puLayer = ((StringToken) PuLayerFile.get(0)).stringValue();
			
			
			_handle = new File(_path);
			_needNew = !_handle.exists();
			_doChange = true;
			_append = false;
			
			_writer = null;
			if (_doChange) {
				if (_needNew) {
					try {
						_parentDir = _handle.getParentFile();
						if (!_parentDir.exists()) {
							_mkdirsSuccess = _parentDir.mkdirs();
							if (!_mkdirsSuccess) {
								throw new IllegalActionException(this,
										"Parent directory " + _parentDir
												+ " was not successfully made.");
							}
						}
						_handle.createNewFile();
					} catch (Exception ex) {
						_debug("File cannot be created.");
					}
				}
				try {
					_writer = new FileWriter(_handle, _append);
					_writer.write(_text);
					_writer.close();
				} catch (Exception ex) {
					_debug("File cannot be written.");
				}
				
			}
			//copy file part
			_original = ((StringToken) MarxanFile.get(0)).stringValue();
			
			
			// Move or copy the file.
			_file = new File(_original);
			_target = new File(_dir, _file.getName());
			_outfile = pathdir + _file.getName();
            Path srcPath = Paths.get(_original);
            Path dstPath = Paths.get(_outfile);
            File puSrc = new File(puLayer);
            File puDst = new File(pathdir+"pulayer/");
            try {
	/*	
				_inStream = new FileInputStream(_file);
				_outStream = new FileOutputStream(_target);
				int i = 0;
				while ((i = _inStream.read()) != -1) {
					_outStream.write(i);
				}
				_inStream.close();
				_outStream.close();
	*/          
                if(outDir.substring(0,1) == "/" || outDir.substring(0,1) == "~"){
                    new File(outDir).mkdir();
                }else{
                    String outputdir = pathdir + outDir;
                    new File(outputdir).mkdir();
                }
                Files.copy(srcPath,dstPath,StandardCopyOption.COPY_ATTRIBUTES);
				FileUtils.copyDirectory(puSrc,puDst);
                _copy = new StringToken(pathdir);	
			} catch (Exception ex) {
				_debug("File cannot be copied or moved.");
			}
			
			MarxanLoc.send(0,_copy);
		}
		

		
		
	}
	
	private String textOne = "Input file for Annealing program.;;"+
							"This file generated by Qmarxan;"+
							"created by Apropos Information Systems Inc.;;"+
							"General Parameters;"+
							"VERSION 0.1;"+
							"BLM 1;"+
							"PROP 5.00000000000000E-0001;"+
							"RANDSEED -1;"+
							"BESTSCORE -1.00000000000000E+0000;"+
							"NUMREPS 10;;"+
							"Annealing Parameters;"+
							"NUMITNS 1000000;"+
							"STARTTEMP -1.00000000000000E+0000;"+
							"COOLFAC 0.00000000000000E+0000;"+
							"NUMTEMP 10000;;"+
							"Cost Threshold;"+
							"COSTTHRESH 0.00000000000000E+0000;"+
							"THRESHPEN1 1.40000000000000E-0001;"+
							"THRESHPEN2 0.00000000000000E+0000;;"+
							"Input File;"+
							"INPUTDIR ";
	
	private String textTwo = ";SPECNAME spec.dat;"+
							"PUNAME pu.dat;"+
							"PUVSPRNAME puvspr.dat;"+
							"BOUNDNAME bound.dat;"+
							"MATRIXSPORDERNAME puvspr_sporder.dat;;"+
							"Save Files;"+
							"SCENNAME output;"+
							"SAVERUN 3;"+
							"SAVEBEST 3;"+
							"SAVESUMMARY 3;"+
							"SAVESCEN 2;"+
							"SAVETARGMET 3;"+
							"SAVESUMSOLN 3;"+
							"SAVELOG 1;"+
							"SAVESNAPSTEPS 0;"+
							"SAVESNAPCHANGES 0;"+
							"SAVESNAPFREQUENCY 0;"+
							"OUTPUTDIR ";

	
	private String textThree =	";;Program control.;"+
								"RUNMODE 1;"+
								"MISSLEVEL 9.50000000000000E-0001;"+
								"ITIMPTYPE 1;"+
								"HEURTYPE 0;"+
								"CLUMPTYPE 0;"+
								"VERBOSITY 3;;"+
								"SAVESOLUTIONSMATRIX 3";
	
	private String fixedInput;
	private String inDir;
	private String outDir;
    private String puLayer;
    private String fixedInputTwo;
	private String fixedInputThree;
	private String _path;
	private String pathdir;
	private String _text;
	private File _handle;
	private boolean _needNew;
	private boolean _doChange;
	private boolean _append;
	private File _parentDir;
	private boolean _mkdirsSuccess;
	private FileWriter _writer;
	
//file copy var
	private String _original;
	private File _dir;
	private String _outfile;
    private File _file;
	private File _target;
	private FileInputStream _inStream;
	private FileOutputStream _outStream;
	private StringToken _copy;
}


