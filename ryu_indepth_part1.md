### How ryu-manager works

* A list of applications is instantiated. If no apps is provided via command line, a list will contain only the *ryu.controller.ofp_handler* application

* Instance of application manager is created

* There are 3 stages of working with apps: *loading, instantiating and starting*

#### Loading apps

* AppManager attempts to load each specified application by first importing a module corresponding to the app's name and than by making an inspection of imported module. Module must define a subclass of RyuApp - only in this case inspection will be passed and defined class will be returned (see *ryu.base.app_manager.AppManager.load_apps*) in order to be saved inside a dictionary which maps application names to corresponding classes. This is *the stage of applications loading*.
    
* The dictionary mapping app names to corresponding classes will be required for apps instantiation.

#### Instantiating apps

* Instantiation of an app means creating an instance of a class and registering an app within RYU framework.

* In this very step RYU logs something like *instantiating app ryu/app/simple_switch.py of SimpleSwitch*
    
* Registration of an app means registering of event handlers.
    
    1. All methods of the application instance *decorated by either set_ev_cls or set_ev_handler* are registered as *handlers of events*. 
    2. The detection of such handlers is performed by calling *ryu.controller.handler.register_instance*.
    3. Registration of detected handler is the responsibility of RyuApp (*ryu.base.app_manager.RyuApp.register_handler*).
    
* Finally on this stage the another mapping is created: from app name to corresponding **class instance**

#### Starting apps

* After all apps are instantiated they begin to start. Starting each app leads to creation of a new thread.

After all apps are started *ryu-manager* waits for their threads are finished

#### Events processing

* One source of events for RYU apps is *OpenFlow controller* - it transforms into events messages received from switches


### Questions

* Observers vs handlers of events? This relates to the question *when to use the set_ev_cls and when the set_ev_handler*

* What are *bricks*? See working whith them during apps instantiation

