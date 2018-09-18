## How ryu-manager works

* A list of applications is instantiated.</br>
  If no apps is provided via command line, this list will contain only the *ryu.controller.ofp_handler* application

* Instance of application manager is created

* There are 3 stages of working with apps: *loading context, instantiating and starting an apps*


### Loading apps & context

* AppManager attempts to load each specified application by first importing a module corresponding to the app's name and than by making an inspection of imported module. Module must define a subclass of RyuApp - only in this case inspection will be passed and defined class will be returned in order to be saved inside a dictionary which maps application names to corresponding classes. 
  This is *the stage of applications loading* (see *ryu.base.app_manager.AppManager.load_apps*). The dictionary mapping app names to corresponding classes will be required for apps instantiation.

* In this stage AppManager also creates all *context classes* - these are classes which other applications want to use.

    1. each RyuApp may define the *_CONTEXTS* field, which is a dictionary for classes required by this app
    2. AppManager fills own dictionary of *context classes* on loading applications (see above), checking presense of *context classes* for each loaded app by using class method *ryu.base.app_manager.RyuApp.context_iteritems*
    3. Concrete instances of these *context classes* are created in order to be later used during apps instantiation:
    ```python
    app_mgr.instantiate_apps(**contexts)
    ```
The concrete example of using context is how *SimpleSwitchRest13* gains access to the instance of *WSGIApplication*.


### Instantiating apps

* Instantiation of an app means creating an instance of a class and *registering an app within RYU framework*.

* Registration of an app means registering of event handlers.
    
    1. All methods of the application instance *decorated by either set_ev_cls or set_ev_handler* are registered as *handlers of events*. 
    2. The *detection of such handlers* is performed by calling *ryu.controller.handler.register_instance*.
    3. Registration of detected handler is the responsibility of RyuApp (*ryu.base.app_manager.RyuApp.register_handler*).
    
* Finally on this stage the another mapping is created: from app name to corresponding **class instance**


### Starting apps

* After all apps are instantiated they begin to start. **Starting each app leads to creation of a new thread**.

* The working thread of RyuApp is designated to processing of events received from a queue (which is an *eventlet.queue.LightQueue*).
  Upon receiving each event the application could determine a list of handlers to process this concrete event:
  ```python
  handlers = self.get_handlers(ev, state)
  ```

* If at least one app is going to use *WSGIApplication* then WSGIServer is to be launched.

After all apps are started *ryu-manager* waits for their threads are finished


### Events processing

* One source of events for RYU apps is *OpenFlow controller* - it transforms into events messages received from switches

* Differences between the *set_ev_cls* and *set_ev_handler* decorators:

    1. the former is used to ...**TODO** 
    2. the latter is used to ...**TODO**    


### Questions

* Observers vs handlers of events? 
* What are *bricks*? See working whith them during apps instantiation

