@echo off
set PAUSE_ERRORS=1
call bat\SetupSDK.bat
call bat\SetupApplication.bat

:target
goto desktop
::goto android-debug
::goto android-test
::goto ios-debug
::goto ios-test


:desktop
:: http://help.adobe.com/en_US/air/build/WSfffb011ac560372f-6fa6d7e0128cca93d31-8000.html

::set SCREEN_SIZE=SamsungGalaxyS
::set SCREEN_SIZE=NexusOne
::set SCREEN_SIZE=iPhone5Retina
::set SCREEN_SIZE=iPhoneRetina
::set SCREEN_SIZE=WVGA
::set SCREEN_SIZE=512x384:1024x768
::set SCREEN_SIZE=2560x1600:400x640
::set SCREEN_SIZE=667x375:375x667
set SCREEN_SIZE=1104x621:621x1104

::set SCREEN_SIZE=iPad
::set SCREEN_SIZE=768x512:384x512


:desktop-run
echo.
echo Starting AIR Debug Launcher with screen size '%SCREEN_SIZE%'
echo.
echo (hint: edit 'Run.bat' to test on device or change screen size)
echo.
adl -screensize %SCREEN_SIZE% "%APP_XML%" "%APP_DIR%"
if errorlevel 1 goto error
goto end


:ios-debug
echo.
echo Packaging application for debugging on iOS
echo.
set TARGET=-debug-interpreter
set OPTIONS=-connect %DEBUG_IP%
goto ios-package

:ios-test
echo.
echo Packaging application for testing on iOS
echo.
set TARGET=-test-interpreter
set OPTIONS=
goto ios-package

:ios-package
set PLATFORM=ios
call bat\Packager.bat

echo Now manually install and start application on device
echo.
goto error


:android-debug
echo.
echo Packaging and installing application for debugging on Android (%DEBUG_IP%)
echo.
set TARGET=-debug
set OPTIONS=-connect %DEBUG_IP%
goto android-package

:android-test
echo.
echo Packaging and Installing application for testing on Android (%DEBUG_IP%)
echo.
set TARGET=-captive-runtime
set OPTIONS=
goto android-package

:android-package
set PLATFORM=android
call bat\Packager.bat

adb devices
echo.
echo Installing %OUTPUT% on the device...
echo.
adb -d install -r "%OUTPUT%"
if errorlevel 1 goto installfail

echo.
echo Starting application on the device for debugging...
echo.
adb shell am start -n air.%APP_ID%/.AppEntry
exit

:installfail
echo.
echo Installing the app on the device failed

:error
pause
