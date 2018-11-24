% importing data collected by sensor

% data = collect_data()
% inv_file = data;
% inv_file(inv_file==0) = [];

max_diff = 5;
data = importdata('pretty_accurate.txt');
new_data = data;
for i=1:length(new_data)-1
    value_1 = new_data(i);
    value_2 = new_data(i+1);
    
    d = abs(value_1-value_2);
    if d > max_diff
        for j=1:20
            if j+i < length(new_data) && abs(new_data(i+j)-value_1) < max_diff 
                new_data(i+1) = new_data(i);
                break
            end
        end
    end
end

inv_file = new_data;

% inv_file = medfilt1(inv_file,3);

% plateau identification code (finding the walls)
i = 1;
threshold = 10;
% for angle correction to radians
angle = 0.9*pi/180;
% each row of side_distance stores the distance of two midpoints of wall
% each row of side_angle stores the angle of two midpoints of wall
side_distance = [];
side_angle = [];
starts = [];
midpoints = [];
ends = [];
% look at difference between each value of distance
differences = diff(inv_file);

while i < length(differences)
    count = 0;
    if abs(differences(i)) < threshold        
        count = count + 1;
        for j=i:length(differences)
            if abs(differences(i + count)) <= threshold && (count + i) < length(differences) 
                count = count + 1;
            end
        end
        if count > 35
            midpoint = i + floor((count+1)/2);
            midpoint_1 = midpoint - 1;
            side_distance = [side_distance; [inv_file(midpoint+1) inv_file(midpoint)]];
            side_angle = [side_angle; [angle*midpoint_1 angle*midpoint]];
            % side_angle = [side_angle; [angle*(i+count)*.85 angle*(i+(count+1)*.85)]];
            % side_angle = [side_angle; [angle*i angle*(i+count)]];
            midpoints = [midpoints; midpoint];
            starts = [starts; i+1];
            ends = [ends; i+count+1];
        end
    end
    i = i + count + 1;
end

% finding the equation between the side points 
side_eqns = [];
for i=1:length(side_distance)
    delta_y = side_distance(i,2)*sin(side_angle(i,2)) - side_distance(i,1)*sin(side_angle(i,1));
    delta_x = side_distance(i,2)*cos(side_angle(i,2)) - side_distance(i,1)*cos(side_angle(i,1));
    slope = delta_y/delta_x;
    intercept = side_distance(i,1)*sin(side_angle(i,1)) - slope*side_distance(i,1)*cos(side_angle(i,1));
    side_eqns = [side_eqns; [slope intercept]];
end

% finding points of intersection btwn sides
syms x;
poi = [];
for i = 1: length(side_eqns)
    if i == 1
        start_x = solve(side_eqns(i,1)*x + side_eqns(i,2) == side_eqns(length(side_eqns),1)*x + side_eqns(length(side_eqns),2), x);
        end_x = solve(side_eqns(i,1)*x + side_eqns(i,2) == side_eqns(i+1,1)*x + side_eqns(i+1,2), x);
    elseif i == length(side_eqns)
        start_x = solve(side_eqns(i,1)*x + side_eqns(i,2) == side_eqns(i-1,1)*x + side_eqns(i-1,2), x);
        end_x = solve(side_eqns(i,1)*x + side_eqns(i,2) == side_eqns(1,1)*x + side_eqns(1,2), x);
    else
        start_x = solve(side_eqns(i,1)*x + side_eqns(i,2) == side_eqns(i-1,1)*x + side_eqns(i-1,2), x);
        end_x = solve(side_eqns(i,1)*x + side_eqns(i,2) == side_eqns(i+1,1)*x + side_eqns(i+1,2), x);
    end 
    
    % put x's in proper order (least:greatest)
    if double(start_x) < double(end_x)
        poi = [poi; [double(start_x) double(end_x)]];
    else
        poi = [poi; [double(end_x) double(start_x)]];
    end
end

% plotting each of the lines and where they intersect
figure
for i = 1: length(poi)
    x_range = poi(i,1):poi(i,2);
    y_range = side_eqns(i,1)*x_range + side_eqns(i,2);
    plot(x_range, y_range);
    hold on
end
plot(0,0,'r*')
text(5,5,'Transducer')
xlabel('Distance (mm)')
ylabel('Distance (mm)')

figure
hold on
plot(inv_file)
for i=1:length(midpoints)
    plot(midpoints(i), inv_file(midpoints(i)), 'ro')
    plot(starts(i), inv_file(starts(i)), 'go')
    plot(ends(i), inv_file(ends(i)), 'bo')
end
xlabel('Steps of Rotation (0.9 degrees/step)')
ylabel('Distance (mm)')
