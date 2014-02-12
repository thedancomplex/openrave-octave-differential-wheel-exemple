function [x,y] = getxy(robotid)

  T = reshape(orBodyGetTransform(robotid),3,4);
  x = T(1,4);
  y = T(2,4);
  z = T(3,4);
%  R = [ T(1,1:3); T(2,1:3); T(3,1:3)];

end
