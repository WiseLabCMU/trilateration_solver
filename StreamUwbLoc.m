function StreamUwbLoc()
% UWB localizztion in 3D using gradient descent
% Ranges received through MQTT
% Est Pos published on MQTT

    clc; clear; close all;
    
    % 3D coordinates of beacon
    BeacCoord = [0 1.24 1.22;...% A
        0 0 1.22;... % B
        0.82 0 1.22;...%D
        0 0.283 0.867;...%E
        ];
    
    BufferSize = size(BeacCoord,1); % size of buffer which has to be filled up for location estimation
    mud_state = [0 0 0];
    data_buffer = zeros(BufferSize,2); % node ID | range
    ind_buffer = 1; % this index rolls over when end-of-buffer reached
    
    % Plot that updates UWB node position
    figure; hold on;
    scatter3(BeacCoord(:,1),BeacCoord(:,2),BeacCoord(:,3),60,'filled','MarkerFaceColor','r');
    title('Location');

    jointplot = scatter3(mud_state(1),0,0,60,'filled','MarkerFaceColor','b');
    jointplot.XDataSource = '[mud_state(1)]';
    jointplot.YDataSource = '[mud_state(2)]';
    jointplot.ZDataSource = '[mud_state(3)]';

    
    axis equal; %axis vis3d; 
    xlim([-10 30]); ylim([-10 30]);
    grid on; set(gca,'fontsize',16); xlabel('x'); ylabel('y'); zlabel('z');

    %MQTT
    myMQTT = mqtt('tcp://johnpi.local');
    uwb_mud = myMQTT.subscribe('topic/uwb_range_mud');
    uwb_mud.Callback = @(topic,msg) uwb_mud_func(topic,msg);
    
    %publish(myMQTT, 'topic/uwb_loc', 'testMessage03');
      
    while(1)
        % Update position on plot
        refreshdata(jointplot,'caller');
        drawnow;
        
        % Publish on MQTT
        s = ['{"x":',num2str(mud_state(1),'%.2f'),',"y":',num2str(mud_state(2),'%.2f'),',"z":',num2str(mud_state(3),'%.2f'),'}'];
        publish(myMQTT, 'topic/uwb_loc', s);
    end
    myMQTT.disconnect();

    function uwb_mud_func(~,msg)
        uwb = sscanf(msg,'%d,%f,%d,%f');
        node_id = uwb(1)+1;
        range = uwb(2);
        data_buffer(ind_buffer,:) = [node_id range];
        ind_buffer=ind_buffer+1;
        
        if ind_buffer==BufferSize+1 % circular buffer
            ind_buffer = 1;
            %data_buffer
        end
        
        [~,ind]=unique(data_buffer(:,1)); %  unique beacon IDs only
        data_buffer_unique =  data_buffer(ind,:);
        % Solve for location 
        [mud_state] = gradient_descent_solver(BeacCoord, [data_buffer_unique(:,1), data_buffer_unique(:,2)]);
        
    end
end

