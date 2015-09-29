<h2 id="whatsrobotrunner">What's Robot Runner?</h2>

<p>Robot Runner is one of my internal test apps.  I use it for working with Bluetooth techniques. It's a fun app since it has sensors, animation and involves some hardware hacking with an Arduino module and breadboard.</p>

<p>Robot Runner is an iPhone app written with Swift in XCode that connects to an embedded controller (the Arduino board) using Bluetooth Low Energy (a BLE shield attached to the Arduino).  The architecture of the app is in the diagram below.</p>

<p><img src="/content/images/2015/07/Robot-Runner-iPhone.jpg" alt="" /></p>

<p>The iPhone app starts and stops the robot, and reads temperature and ambient light intensity sensors on the robot.  It's a good hacking solution since it incorporates many different elements used in mobile connected device applications.</p>

<h2 id="robotrunnerapplewatchdesignobjective">Robot Runner Apple Watch Design Objective</h2>

<p>For the Watch project, the objective is to add a to the existing app the ability for the user to connect to the Robot using the Watch instead of the iPhone.  This is a typical use case for the Apple Watch -- giving the user the ability to use the core functions of the app from the watch.  The final architecture will be as follows:</p>

<p><img src="/content/images/2015/07/Robot-Runner-iPhone-and-Watch.jpg" alt="" /></p>

<p>Currently, all 3rd-party apple Watch apps are built as extensions to iPhone apps. In the diagram above, it's not (yet) possible to eliminate the iPhone entirely, but it is possible to leave the phone in standby (in a pocket or purse, or in the next room) and let the watch wearer still use the app functions.</p>

<p>The Watch app remains connected to the iPhone through a Bluetooth "umbilical cord".  In MVC terms, the Models and Controller are still resident in the phone, and only the View is resident on the watch.  Maybe that will change in the future, but for now, it makes sense. Leaving the Controller on the iPhone certainly will conserve the watch's battery and CPU.</p>

<h2 id="softwarearchitecture">Software Architecture</h2>

<p>A significant part of Robot Runner is the code to scan for the Bluetooth devices, connect to them, and once connected send commands and read sensor values.  In the current iPhone app (Robot Runner.app, in purple within the below diagram), all of the code used by the iPhone app is contained within the single iPhone app target.</p>

<p><img src="/content/images/2015/07/Robot-Runner-Software-Architecture.jpg" alt="" /></p>

<p>The Watch app (Robot Runner WatchKit.app, in blue), won't connect directly to the Arduino module's Bluetooth interface, but will do so via the Robot Runner WatchKit Extension.app (green), which runs on the iPhone. So far so good. But there's a wrinkle that requires some re-architecting.</p>

<p>Once the Apple Watch is added to the solution, the two Bluetooth modules (BTDiscoverySvc.swift and BTPeripheralSvc.swift) will need to be used by Robot Runner.app and Robot Runner Watchkit Extension.app.  However, although these apps are installed together, they run in different sandboxes.  So, we either need to compile and link the two Bluetooth swift modules into both targets, or break them out into a common framework.  The framework is easier to maintain and reduces the runtime footprint, so I chose that path.  This framework is called RobotRunner.framework.</p>

<p>This sandbox separation also restricts sharing of data between the Apple Watch and iPhone controllers.  Specifically, the project needs to have a single app group with entitlements granted to both the iPhone app and Watch Extension targets. Using the app group, the iPhone app and watch extension can share data using flat files, Core Data/SQLite and/or NSUserDefaults.  Robot Runner does't need a shared data capability (yet), so this wasn't a factor in this project.</p>

<h2 id="puttingthepiecestogether">Putting the pieces together</h2>

<p>With the refactoring of common code into the framework, the rest of the development is straightforward.  The logic to connect to and communicate with the Robot's Bluetooth controller was expressed in the Robot Runner WatchKit Extension.app, and the UI was designed in the Robot Runner WatchKit.app.</p>

<p>I'm happy to report that no significant challenges were encountered. There are differences between UIKit used for the iPhone UI and WatchKit used for the Watch UI, and the controller lifecycle states are named differently (and there are fewer of them).  So, certainly, there's a learning curve for existing iOS developers.</p>

<p>I expected challenges with the Core Bluetooth modules and delegates (either because of the WatchKit controller or the re-factoring into the Framework), but I was pleasantly surprised not to encounter any unusual challenges.  A little bit of change related to the framework refactoring, but overall all of the Core Bluetooth code worked as-is.</p>

<h2 id="thefinalresults">The Final Results</h2>

<p>Here's a side-by-side (or over/under if you're on a phone device) comparison of the UI for the iPhone and Apple Watch versions of Robot Runner.  Note that in moving from the 4.7" iPhone screen to the 38mm-42mm watch screen there has been no loss of functionality.</p>

<p><img src="https://github.com/robkerr/RobotRunner/blob/master/images/Robot-Runner-iPhone.jpg" alt="" />
<img src="/content/images/2015/07/RobotRunnerAppleWatch.jpg" alt="" /></p>

<p>All of the same information is displayed. The command button and sensor outputs are still on the same screen together.  Even the animated Robot renders exactly the same using the same frame images (he runs when the robot is in a run state, and is stopped when the robot is in a stopped state).</p>
