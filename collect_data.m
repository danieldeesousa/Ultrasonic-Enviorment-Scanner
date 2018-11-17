function data = collect_data
    % This script collects data from Arduino  
    % Clear previous variables
    clear all 
    clear a; 
    delete(instrfindall);
    clc; 

    % Get user input regarding which COM port to utilize
    % comport = input('COM port Arduino is attached to [i.e. COM1, COM2, ... etc.]: ','s'); 
    comport = 'COM6';
    a = serial(comport,'BaudRate',9600);
    fopen(a); 

    % This loop empties the serial port buffer
    while a.BytesAvailable > 0  
        temp = fscanf(a, '%f');
    end

    %input('Ready to collect data? Press ''Enter'' to continue...','s');
    no_of_points = 400; % 1 point = 1 ms ????? Doesn't seem quite right
    % ^ Length of recording can be read from Arduino as well
    % fscanf(arduino_port, '%f');

    % Collect data
    while fscanf(a, '%f') == 0
        disp('wheeee')
    end
    for i=1:no_of_points
      data(i)= fscanf(a, '%f');     % Read in the first temperature sensor
      pause(0.01)
      fprintf('%f, %f \n',i,data(i));
    end
    fclose(a)
    clear arduino_port
    disp('Data collection completed.') 

    % Write data to a file  
    fid=fopen('button_press.txt','w') ; 
    for i=1:no_of_points
        fprintf(fid, '%d ',data(i)) ; 
    end 
    fclose(fid) ; 

    % Plot data
    plot(data) 
    xlabel('Time (ms)'); 
    ylabel('On/Off'); 
    title('Button Press'); 
    grid; 
end
