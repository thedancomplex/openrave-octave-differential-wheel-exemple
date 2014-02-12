addpath("/usr/share/openrave-0.8/octave/") 

orEnvLoadScene('/home/student/projects/openrave-octave-differential-wheel-exemple/maze2.env.xml', 1);

% pay attention to this line, I found different commands to switch on
% the physics engine but just 'physics ode' works fine
orEnvSetOptions('physics ode')
orEnvSetOptions('debug 0')
orEnvSetOptions('gravity 0 0 -9.8')
orEnvSetOptions('timestep 0.001')
orEnvSetOptions('simulation stop')
orEnvSetOptions('simulation start')

logid = orEnvCreateProblem('logging')
orProblemSendCommand('savescene filename myscene.env.xml',logid)

robots = orEnvGetRobots()
robotid=robots{1,1}.id

% switch on "all" sensors (at the moment we have just one)
sensor = orRobotGetAttachedSensors(robotid);
for i=0:length(sensor)
   orRobotSensorConfigure(robotid, i, 'poweron');
   orRobotSensorConfigure(robotid, i, 'renderdataon');
end

% we want to use the existing implementation of a differential
% driven robot (two wheels located on one axes)
success = orRobotControllerSet(robotid, 'odevelocity')
success = orRobotControllerSend(robotid, 'setvelocity 1 1')

wl = 0;
wr = 0;
k=1.5;
disp('start')
while(1)
  pause(0.05)
  velocities=2*rand(1,orRobotGetActiveDOF(robotid));
  velocities=[wl,wr];
  velocities = velocities*k;
%  velocities=[wl,wr]
  success = orRobotControllerSend(robotid, ...
                                  ['setvelocity ', num2str(velocities)]);
  data = orRobotSensorGetData(robotid,0);
  % check the completeness of a laser measurement 
  if min(size(data.laserrange))~=0
     % calculate the range from distance in all dimensions 
     range=sqrt(data.laserrange(1,:).^2+...
                data.laserrange(2,:).^2+...
                data.laserrange(3,:).^2);
     % filtering "0" values (No idea were they come from)
     range(range==0)=NaN;
%     min(range)
%     if min(range)<1.0
%        break
%     end
  end

  if ( mean(range(1:30)) < 1.5)
    wl = -1.0
    wr = 1.0
  else
    wl = 1.0
    wr = 0.7
  end

%  figure(1)
%  plot(range)
%  set(vh
end
% switch off the robot
success = orRobotControllerSend(robotid,...
                               'setvelocity 0 0');
