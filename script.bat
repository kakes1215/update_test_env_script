echo off

:beginning

echo                                    __               __                  __
echo /'\_/`\                           /\ \__           /\ \__              /\ \__
echo/\      \    ___   __  __    __    \ \ ,_\   ___    \ \ ,_\    __    ___\ \ ,_\
echo\ \ \__\ \  / __`\/\ \/\ \ /'__`\   \ \ \/  / __`\   \ \ \/  /'__`\ /',__\ \ \/
echo \ \ \_/\ \/\ \L\ \ \ \_/ /\  __/    \ \ \_/\ \L\ \   \ \ \_/\  __//\__, `\ \ \_
echo  \ \_\\ \_\ \____/\ \___/\ \____\    \ \__\ \____/    \ \__\ \____\/\____/\ \__\
echo   \/_/ \/_/\/___/  \/__/  \/____/     \/__/\/___/      \/__/\/____/\/___/  \/__/

:: Menu for three options
echo.
echo ******************************************
echo.
echo 1) Move branch into the Test Environment
echo 2) Update Script from Github
echo 3) Exit the Script
echo.
echo ******************************************


::Have user select option based on the menu above
set /P option=Choose an option above (1, 2, or 3):
if /i %option% == 2 goto :updateScript
if /i %option% == 3 goto :endScript

:: Excecutes when the user chooses option 1
goto :part1
@echo Moving to part 1 in the script

::Executes when user enters option 2 and updates the move_to_test_script
:updateScript
echo.
echo Updating Script with new changes...
PAUSE
echo.
git fetch
git pull
echo.
echo Finished updating Script
PAUSE
goto :beginning
:end

::Executes when user enters option 3 and closes the script
:endScript
echo.
echo Closing script
PAUSE
exit
:end

:part1
echo.
echo Running Script to Move Code into Available for Testing
PAUSE
echo.
echo -------------------------------------------------------------------------
echo PART ONE - DOWNLOAD REPOSITORY

set /P repository=Please Enter Repository Name:

::Clone the repository specified above
echo.
git clone git@github.com:kstateome/%repository%.git
cd %repository%\ && echo.
echo Finished Copying %repository% to your Desktop
PAUSE
echo.

:part2
echo -------------------------------------------------------------------------
echo PART TWO - CHECKOUT TEST BRANCH
set /P testBranch=Please Enter Test Branch Name:
echo.
git checkout %testBranch% && echo.
echo You are currently using the following test branch: %testBranch%
PAUSE
echo.

:part3
echo -------------------------------------------------------------------------
echo PART THREE - SHOW LATEST COMMIT IN THE TEST BRANCH AND RESET IT IF NECESSARY
echo.
echo The latest merge branch that is currently in the test branch is shown below...
echo  __________________________________________________________
echo.
::echo Author: && git log --pretty=format %%an
::git log -n 1 --pretty=format:"%%H commited %%ar by %%an" : "%%s"
git log -n 1
echo.
echo  __________________________________________________________
echo.

::Remove latest commit option
set /P removeCommit=Do you want to remove this commit?(y/n):
echo.
if /i  %removeCommit% == y  goto :yes
goto :part4
:yes
echo.
echo Resetting the latest commit...
git reset --hard HEAD~1
git push -f origin %testBranch%
echo.
echo The latest commit is now removed
PAUSE
:end
echo.

:part4
echo ------------------------------------------------------------------------
echo PART FOUR - CHECKOUT MERGE BRANCH
set /P mergeBranch=Please Enter Merge Branch Name:
echo.
git checkout %mergeBranch% && echo.
echo You are currently using the following merge branch: %mergeBranch%
PAUSE
echo.

:part5
echo ------------------------------------------------------------------------
echo PART 5 - UPDATE MERGE BRANCH
echo.
echo The merge branch will now be updated with what is currently in production (master branch)
PAUSE
echo.
git merge master
echo.
echo ********************************************************************************************************************
echo.
echo IMPORTANT: If the above dialog indicates merge conflicts, Contact a developer for assistance and exit this process
echo.
echo ********************************************************************************************************************
echo.
set /P exitAnswer=Do you wish to exit this process? (y/n):
echo.
if /i  %exitAnswer%  ==  y  goto :yes
git push
goto :part6
:yes
cd ../
rmdir /S /Q %repository%
echo.
echo The screen will now close
PAUSE
exit
:end


echo.
:part6
echo ---------------------------------------------------------------------------
echo PART 6 - Update test branch
echo Showing most latest logs...
echo __________________________________________________________
echo.
git log -n 1
::git log -n 1 --pretty=format: %%H commited %%ar by %%an : %%s
echo.
echo __________________________________________________________
echo.
set /P hashCode=Copy the hash code above and paste here:
echo.
::change test branch to point to hashcode
echo *****************************************************************************************************
echo.
echo IMPORTANT: %testBranch% of %repository% will now have the following commit %hashCode%
echo.
echo *****************************************************************************************************
echo.
set /P correct=Is this information correct?(y/n):

if /i  %correct%  ==  y  goto :part7

::If the user enters n for No then the repository is removed and returns to the beginning
cd ../
rmdir /S /Q %repository
goto :beginning


::If the user enters y for Yes the test branch is then updated with the merge branch
:part7
echo -----------------------------------------------------------------------------------------------
echo PART SEVEN - UPDATE THE TEST BRANCH WITH THE MERGE BRANCH
echo.
git branch -f %testBranch% %hashCode%
git push -f origin %testBranch%
:end
echo.
echo The test branch is now updated with the merge branch
PAUSE

echo.
echo Removing repository...
cd ..\
rmdir /S /Q %repository%
echo.

:part8
echo ----------------------------------------------------------------------------------------------
echo PART EIGHT - OPEN JENKINS PAGE
echo.
echo Opening Jenkins Webpage
PAUSE
start "" https://jenkins.ome.ksu.edu/job/its/job/%repository%/job/%testBranch%
echo.
echo.
goto :beginning
