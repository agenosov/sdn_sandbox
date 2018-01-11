### Overall

1. Organize directory structure - using the Google's *repo* tool or manually (if SSH access to github isn't possible due to proxy).
    - in case of manual setup, look [here](https://github.com/Juniper/contrail-vnc/blob/master/default.xml) how the structure is to be organized)
2. Launch *./third_party/fetch_packages.py* to obtain 3-rd party dependencies

#### Notes about dependencies on Ubuntu

* Some 3-rd parties are not fetched via the py- script, as it is provided from (?) additional PPA repository.

* See *./tools/packages/debian/contrail/debian/builddep.trusty* - here is a full list of packages which are **not to be fetched**.

1. SConstruct script imports the *tools/build/rules.py*

2. SConstruct script creates the **default construction environment** and than attaches a *configure context to this environment* by calling the *Configure* function, which is inside the *SCons.SCript.SConscript* module.
   Some notes about **different types of environments** which SCons distinguishes:
   * _external environment_ - the set of vars in the user's environment, available through the Python *os.environ* dict
   * _construction environment_ - object creating within SCons script, can be initialized with values from external environment
   * _execution environment_ - values that SCons set when *executing an external command to build targets*.

### Setting up build environment

1. Inside the *rules.SetupBuildEnvironment* function there is a check for build environment (as part of **the basic framework for multi-platform build configuration in SCons**, which ends with calling the *conf.Finish()* method)

2. There are some calls the *env.AddMethod* to add additional functions as a methods (*Scons MethodWrapper*) of the *construction environment*.

3. Then there are several settings for values of the *construction environment*:
    - OPT - defines optimization level (note that in case of specifying the *--opt=production* on Linux, **-O3** option will be appended to *CCFLAGS*)
    - Note how the *TOP_BIN*, *TOP_LIB* and *TOP_INCLUDE* are set - there is a _#_ at the beginning of the path (SCons interprets such path as **relative to the top-level SConstruct** directory)
    - INSTALL_BIN, INSTALL_LIB, INSTALL_CONF, etc.
    - The *--root* custom option can be used to set a one single path for the above options which are assumed to accept a path.
    - SANDESH - path to the *sandesh compiler*
    - REPO_PROJECTS - dictionary to map paths to repos (received by invoking the *repo list* command and processing it's output). **Seems that it's not used**
    - the *CONTRAIL_COMPILE_WITHOUT_SYMBOLS* environment variable instructs to not add **debug symbols**

4. Append several *builders* to the *construction environment* (there is a *$BUILDERS* variable in an environment which maps names to builder objects)

5. Then in the top-level *SConstruct* file there is a listing of the *SConscript* files to be included in the build (some of them are *optional*).   SConscript files use the *DefaultEnvironment* function to return the **ALREADY initialized construction environment**.


### Controller build

1. There are definitions of *pseudo-targets* for tests (inside the *SConscript* file in the *controller* directory). So tests can be built by typing:
    scons -Q test

2. Inside the *controller/src/SConscript* file there is a call to the *DefaultEnvironment.Clone()* method, which returns a *deep copy of the already initialized construction environment*. Then this copy is used to clone another environments in several places.

3. For the all SConscript files located under the *controller/src* directory, the *BuildEnv* is created (to be imported in sub-scripts) as a clone of the default environment.
