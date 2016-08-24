environments {
    '11.6dev' {
	    output = 'SharpDev'
		playerVersion = '11.6'
		additionalCompilerOptions = [
                "-swf-version=19",
				"-define+=SCRATCH::allow3d,true",
				"-define+=SHARP::builtWithDevMode,true",
		]
	}
    '11.6' {
        output = 'Sharp'
        playerVersion = '11.6'
        additionalCompilerOptions = [
                "-swf-version=19",
                "-define+=SCRATCH::allow3d,true",
				"-define+=SHARP::builtWithDevMode,false",
        ]
    }
    '10.2' {
        output = 'SharpFor10.2'
        playerVersion = '10.2'
        additionalCompilerOptions = [
                "-swf-version=11",
                "-define+=SCRATCH::allow3d,false",
				"-define+=SHARP::builtWithDevMode,false",
        ]
    }
}
