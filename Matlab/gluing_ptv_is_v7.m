function res=gluing_ptv_is_v7()

%%should plot nice figures

global traj;
global traj_bin;
global ptv;

global log;
log=[];

global eps;
global gluedim;

global tot_glues;
global suc_jump;

warning off all;

global_totalpix_before =[];
global_totalpix_child  =[];
global_breakage_pos    =[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
columns=32;%9;% No of variables in ptv_is files
max_num_per_frame=100;
min_length=5; % Trajectories travel over at least 5 frame
max_jump=30;
min_scale=1e-3; % Trajectories' min length in metric unit
tol=1; % spatial tol for gluing
break_tol=5; % spatial tol for parent child match
dx         = 0.2e-3;
dy         = 0.2e-3;
dz         = 0.4e-3;
d_totalpix = 10;
d_xpx      = 1;
d_ypx      = 1;
d_sumgrv   = 7000;

eps=    [0 0 dx dy dz d_totalpix d_xpx d_ypx d_sumgrv ];%S_ij,L1,L2,L3,vel
gluedim=[    3  4  5  6                              ];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
foll={%'3Nov2010\';
    %'15Nov2010\';
    %'Deb_6Nov2010\';
    %'Exp_07112010\';
    %'Exp_08112010\';
    %'Exp_09112010\';
    %'Exp_10112010\';
    %'Exp_11112010\';
    %'Exp_11112010_REST\';
    %'Exp_12112010\';
    %'Exp_14112010\';
    'missing_breakage_event\'; %%%%%% this is the showcase event
    %'rehab_3Nov2010\';
    %'rehab_15Nov2010\';
    %'rehab_Exp_11112010_REST\';
    %'rehab_Exp_14112010\';
    %'rehab_Exp_15112010\'};
    };
for globi=1:length(foll) %%%%%%%
    %     close all
    clear dummy ar fig_id_count first_count last_count
    dummy=['ptv_is_koni\',foll{globi}];
    
    
    disp('looking into folder, gathering experiments')
    ar=dir([dummy,'Exp*']);
    for k=1:length(ar)
        fig_id_count(k)=k;
        br{k}=dir([dummy,ar(k).name,'\ptv_is_koni*']);
    end
    
    for k=1:length(ar)
        for l=1:length(br{k})
            cr{k,l}=regexp(br{k}(l).name,'\.','split');
            dr(l)=str2num(cr{k,l}{2});
        end
        first_count(k)=min(dr);
        last_count(k)=max(dr);
        clear dr
    end
    
    for fig_id=2;%fig_id_count%[7 8 9 11 12 13 14 15]%[1 2 4 5 7]% 9 10 11 12 13 14]% 5 6 7 8 9 10 11 12 13 14]%2:2%15%[1 2 4 5 7]
        %     close all %%%%%
        te=['dealing with ',ar(fig_id).name];
        disp(te);
        
        first=first_count(fig_id);
        last=last_count(fig_id);
        name_root=[dummy,ar(fig_id).name,'\'];
        
        break_pos=[];
        unbreak_pos_par=[];
        unbreak_pos_child=[];
        start_child=[];
        pixels=[];
        
        suc_jump=0;
        tot_glues=0;
        
        ptv=zeros(last-first+1,max_num_per_frame,columns+1);
        ptv(:,:,1)=-10;
        ptv(:,:,2)=-10;
        num_traj=0;
        traj_bin=[];
        
        disp('reading ptv files')
        for i=first:last
            %         if mod(i,100)==0
            %             i
            %         end
            name=[name_root,'ptv_is_koni.',num2str(i)];
            fid = fopen(name, 'r');
            num_points = fscanf(fid, '%i', [1 1]);    % It has two rows now.
            tmp = fscanf(fid, '%i %i %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', [columns num_points]);
            A=tmp';
            A(:,3:5)=A(:,3:5)*0.001; %%%------ in extended ptv_is_v2,x,y,z are in meter
            A(:,23:25)=A(:,23:25)*0.001; %%%------ in extended ptv_is_v2,x,y,z are in meter
            ptv(i-first+1,1:num_points,1:columns)=A;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fclose(fid);
        end
        
        disp('gluing')
        go=0;
        for i=1:last-first+1
            %         [fig_id i last-first+1 tot_glues suc_jump]
            j=1;
            
            %%%%change to proper num per frame!!! like further below
            ind=find(ptv(i,:,1)>-10);
            num_part=length(ind);
            while j<num_part+1 %max_num_per_frame
                %find trajectories
                go=0;
                if ptv(i,j,columns+1)==0
                    go=1;
                    num_in_traj=init_traj(i,j);
                end
                while go==1
                    old_num_in_traj=num_in_traj;
                    num_in_traj=find_next(num_in_traj,columns,first,last);
                    si=size(traj);
                    if num_in_traj>last-first-i+1 | si(1,1)>last-first-1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        go=0;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %filter, plot, etc....
                        if si(1,1)>min_length %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            num_traj=num_traj+1;
                            ptv=filter_traj();%%%%%%%%%%%%%%%%%%%%%%%%
                            plot_traj(fig_id,first+i-1);
                            update(columns);
                        end
                    elseif old_num_in_traj==num_in_traj%%%%%%%%%
                        go=0;
                        if si(1,1)>min_length
                            %HERE IS THE ACTUAL CHECK IF IT CAN BE GLUED
                            go=glue_traj(max_jump,i,first,last,columns,tol);
                        end
                        if go==0
                            %filter, plot, etc....
                            if si(1,1)>min_length
                                num_traj=num_traj+1;
                                ptv=filter_traj();
                                plot_traj(fig_id,first+i-1);
                                update(columns);
                            end
                        end
                    end
                end
                j=j+1;
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        disp('now doing the actual stuff, the breakage detection')
        
        %plan for breakage detection
        %keep all traj and then process!
        ind_be      = find(traj_bin(:,3)==1);
        ind_en      = ind_be-1;ind_en=[ind_en; length(traj_bin)];ind_en=ind_en(2:end);
        len         = ind_en-ind_be+1;
        nu_tr       = length(ind_be);%% there will be only one 1?
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        f_be        = traj_bin(ind_be,1);
        x_be        = traj_bin(ind_be,4);
        y_be        = traj_bin(ind_be,5);
        z_be        = traj_bin(ind_be,6);
        totalpix_be = traj_bin(ind_be,7);
        strain_be = traj_bin(ind_be,20);
        lambda1_be = traj_bin(ind_be,21);
        lambda2_be = traj_bin(ind_be,22);
        lambda3_be = traj_bin(ind_be,23);
        gradmeas_be = traj_bin(ind_be,24);
        frame_be = traj_bin(ind_be,1);
        size_meas1_be=traj_bin(ind_be,27);
        size_meas2_be=traj_bin(ind_be,28);
        grv_be=traj_bin(ind_be,29);
        xpx_be=traj_bin(ind_be,25);
        ypx_be=traj_bin(ind_be,26);
        vec_be      = [x_be y_be z_be];% totalpix_be];
        
        used=zeros(length(len));
        
        %filter totalpix value
        
        %determine 1)large drops, 2) befor and after drop there should be a
        %difference, 3) the difference should be compensated by some next neighbour
        %trajectory.
        
        %     for j=1:length(gluedim)
        %         accuracy(j)=eps(gluedim(j));%[dx dy dz d_totalpix];
        %     end
        accuracy=eps(gluedim);
        accuracy(4)=accuracy(4)*2;
        acc=repmat(accuracy(1:3),length(ind_be),1);
        
        for i=1:nu_tr
            child_count(i)=0;
            totalpix=zeros(len(i),1);
            ch_totalpix=zeros(len(i),1);
            int_ch_totalpix=zeros(len(i),1);
            for j=2:len(i)-1
                %meas. drop in totalpix
                ch_totalpix(j)=0.5*(traj_bin(ind_be(i)+j-1+1,7)-traj_bin(ind_be(i)+j-1-1,7));
                totalpix(j)=traj_bin(ind_be(i)+j-1,7);
            end
            totalpix(1)=traj_bin(ind_be(i)+1-1,7);
            totalpix(len(i))=traj_bin(ind_be(i)+len(i)-1,7);
%             figure;
%             plot(ch_totalpix,'r')
            for j=1:len(i)
                %measure integrated drop in totalpix
                ba=j-max_jump;
                if ba<1
                    ba=1;
                end
                int_ch_totalpix(j)=sum(ch_totalpix(ba:j));
            end
            
%             figure;plot(int_ch_totalpix)
%             hold on;plot(ch_totalpix,'r')
%             
%             plot(280:310,ch_totalpix(280:310),'.k')
            
%             figure;
%             plot(totalpix,'g')
%             hold on
%             plot(280:310,totalpix(280:310),'.k')
            %find only the local minima
            go=1;
            tmp=int_ch_totalpix;
            list=[];
            while go==1
                mini=min(tmp);
                if mini<-accuracy(4)
                    ind_e=find(tmp==mini);%Beat&Koni nov2011: find(int_ch_totalpix==mini);
                    if length(ind_e)>0 & ind_e>1
                        be=ind_e(1)-max_jump;
                        if be<1
                            be=1;
                        end
                        en=ind_e(1)+max_jump;%%%%%%%%%%%%%%%%%%
                        if en>length(int_ch_totalpix)
                            en=length(int_ch_totalpix);
                        end
                        int_ch_totalpix(be:ind_e(1)-1)=0;
                        int_ch_totalpix(ind_e(1)+1:en)=0;
                        tmp(be:en)=0;
                        maxi=max(totalpix(be:en));
                        ind_b=find(totalpix(be:en)==maxi)+be-1;
                        list=[list;ind_b(1) ind_e(1)]; %%list contains frames with large drops
                    else
                        go=0;
                    end
                else
                    go=0;
                end
            end
            %preparation to determine a filtered drop measurement
            si=size(list);
            num_can=si(1,1);
            for j=1:num_can
                be=list(j,1)-max_jump;
                if be<1
                    be=1;
                end
                en=list(j,2)+max_jump;
                if en>length(int_ch_totalpix)
                    en=length(int_ch_totalpix);
                end
                list(j,3)=nanmean(totalpix(be:list(j,1)-1));
                if en>list(j,2) %% treat if drop at absolute end of traj
                    list(j,4)=nanmean(totalpix(list(j,2)+1:en));
                else
                    list(j,4)=totalpix(list(j,2));
                end
            end
            % up to now the list of potential breakage points ALONG a trajectory i is determined.
            
            % here the end of every traj is added to the list, since it could
            % also be a breakage
            num_can=num_can+1;
            list(num_can,1)=len(i);
            list(num_can,2)=len(i);
            be=list(num_can,1)-max_jump;
            if be<1
                be=1;
            end
            list(num_can,3)=mean(totalpix(be:list(num_can,1)-1));
            list(num_can,4)=0;
            
            %check if anything is close first in time, then in space
            if num_can>0 & len(i)>max_jump
                % now check if the diff between mean before and after 'large enough?'
                % remember to check the quivalent for the traj end, i.e. is the
                % check again whether drop between traj end and begin of new traj large enough?
                ind=find(list(:,3)-list(:,4)>accuracy(4));
                for j=1:length(ind) % j loops through all drops along i
                    %%here begins the story of a new potential breakage
                    totalpix_before=0;
                    totalpix_child=[];
                    % look for child in time
                    ind_time=find(traj_bin(ind_be(i)+list(ind(j),1)-1,1)-max_jump<f_be & f_be<traj_bin(ind_be(i)+list(ind(j),2)-1,1)+4*max_jump & len>max_jump );
                    if length(ind_time)>0
                        vec_en =[traj_bin(ind_be(i)+list(ind(j),1)-1,4) traj_bin(ind_be(i)+list(ind(j),1)-1,5) traj_bin(ind_be(i)+list(ind(j),1)-1,6)];
                        strain_en =traj_bin(ind_be(i)+list(ind(j),1)-1,20);
                        lambda1_en =traj_bin(ind_be(i)+list(ind(j),1)-1,21);
                        lambda2_en =traj_bin(ind_be(i)+list(ind(j),1)-1,22);
                        lambda3_en =traj_bin(ind_be(i)+list(ind(j),1)-1,23);
                        grad_meas_en =traj_bin(ind_be(i)+list(ind(j),1)-1,24);
                        size_meas1_en =traj_bin(ind_be(i)+list(ind(j),1)-1,27);
                        size_meas2_en =traj_bin(ind_be(i)+list(ind(j),1)-1,28);
                        frame_en =traj_bin(ind_be(i)+list(ind(j),1)-1,1);
                        xpx_en =traj_bin(ind_be(i)+list(ind(j),1)-1,25);
                        ypx_en =traj_bin(ind_be(i)+list(ind(j),1)-1,26);
                        vec_en=repmat(vec_en,length(ind_time),1);
                        % look for child in space, to do that the potential begins
                        % of new chlidren are projected to the time frame of vec_en
                        vec_be_proj=proj_be_to_en(vec_be,ind_time,ind_be,ind_en,max_jump,traj_bin(ind_be(i)+list(ind(j),1)-1,1));
                        % here the delta's are normailzed with measurement
                        % accuracy
                        dist=(vec_be_proj-vec_en)./acc(ind_time,:);
                        dist=sum(dist.^2,2).^0.5;
                        ind_begin=find(dist<break_tol*sqrt(3));
                        en_done=0;
                        for k=1:length(ind_begin)+1 % k loops through ALL potential children of i,j
                            
                            if k==length(ind_begin)+1
                                if(ind_be(i)+list(ind(j),2)<ind_en(i)) && ind_en(i)-ind_be(i)>3*max_jump
                                    figure(fig_id);hold on;
                                    xp=traj_bin(ind_be(i)+list(ind(j),1)-1,4);
                                    yp=traj_bin(ind_be(i)+list(ind(j),1)-1,5);
                                    zp=traj_bin(ind_be(i)+list(ind(j),1)-1,7);
                                    zps=traj_bin(ind_be(i)+list(ind(j),1)-1,20);
                                    xc=traj_bin(ind_be(i)+list(ind(j),2)-1,4);
                                    yc=traj_bin(ind_be(i)+list(ind(j),2)-1,5);
                                    zc=traj_bin(ind_be(i)+list(ind(j),2)-1,7);
                                    zcs=traj_bin(ind_be(i)+list(ind(j),2)-1,20);
                                    
                                    
                                    %                                     plot3(traj_bin(ind_be(i):ind_be(i)+list(ind(j),1)-1,4),...
                                    %                                     traj_bin(ind_be(i):ind_be(i)+list(ind(j),1)-1,5),...
                                    %                                     traj_bin(ind_be(i):ind_be(i)+list(ind(j),1)-1,7));
                                    
                                    
                                    % draw parent end
                                    scatter3(xp,yp,zp,10,'r');
                                    % draw child beg
                                    scatter3(xc,yc,zc,20,'g','filled');
                                    % draw line parent-child
                                    plot3([xp xc],[yp yc],[zp zc],'c')
                                    
                                    % clean totalpix figure
                                    figure(100+fig_id);hold on;title('total pix')
                                    
                                    plot3(traj_bin(ind_be(i):ind_en(i),4),...
                                        traj_bin(ind_be(i):ind_en(i),5),...
                                        traj_bin(ind_be(i):ind_en(i),7));
                                    
                                    
                                    break_pos=[break_pos;xp,yp,traj_bin(ind_be(i)+list(ind(j),1)-1,6),zp,zps,traj_bin(ind_be(i)+list(ind(j),1)-1,1),traj_bin(ind_be(i)+list(ind(j),1)-1,21),traj_bin(ind_be(i)+list(ind(j),1)-1,22),traj_bin(ind_be(i)+list(ind(j),1)-1,23),traj_bin(ind_be(i)+list(ind(j),1)-1,24),traj_bin(ind_be(i)+list(ind(j),1)-1,27),traj_bin(ind_be(i)+list(ind(j),1)-1,28),i,traj_bin(ind_be(i)+list(ind(j),1)-1,29),traj_bin(ind_be(i)+list(ind(j),1)-1,25),traj_bin(ind_be(i)+list(ind(j),1)-1,26)];
                                    unbreak_pos_par=[unbreak_pos_par;traj_bin(ind_be(i):ind_en(i),4),traj_bin(ind_be(i):ind_en(i),5),traj_bin(ind_be(i):ind_en(i),6),traj_bin(ind_be(i):ind_en(i),7),traj_bin(ind_be(i):ind_en(i),20),traj_bin(ind_be(i):ind_en(i),1),traj_bin(ind_be(i):ind_en(i),21),traj_bin(ind_be(i):ind_en(i),22),traj_bin(ind_be(i):ind_en(i),23),traj_bin(ind_be(i):ind_en(i),24),traj_bin(ind_be(i):ind_en(i),27),traj_bin(ind_be(i):ind_en(i),28),i*ones(length(traj_bin(ind_be(i):ind_en(i),4)),1),traj_bin(ind_be(i):ind_en(i),29),traj_bin(ind_be(i):ind_en(i),25),traj_bin(ind_be(i):ind_en(i),26)];
                                    start_child=[start_child;xc,yc,traj_bin(ind_be(i)+list(ind(j),2)-1,6),zc,zcs,traj_bin(ind_be(i)+list(ind(j),2)-1,1),traj_bin(ind_be(i)+list(ind(j),2)-1,21),traj_bin(ind_be(i)+list(ind(j),2)-1,22),traj_bin(ind_be(i)+list(ind(j),2)-1,23),traj_bin(ind_be(i)+list(ind(j),2)-1,24),traj_bin(ind_be(i)+list(ind(j),2)-1,27),traj_bin(ind_be(i)+list(ind(j),2)-1,28),i,traj_bin(ind_be(i)+list(ind(j),2)-1,29),traj_bin(ind_be(i)+list(ind(j),2)-1,25),traj_bin(ind_be(i)+list(ind(j),2)-1,26)];
                                    
                                    
                                    
                                    % draw parent end
                                    scatter3(xp,yp,zp,10,'r');
                                    % draw child beg
                                    scatter3(xc,yc,zc,20,'g','filled');
                                    % draw line parent-child
                                    plot3([xp xc],[yp yc],[zp zc],'c')
                                    
                                    
                                    
                                    
                                    % clean strain figure
                                    figure(200+fig_id);hold on;title('strain')
                                    
                                    plot3(traj_bin(ind_be(i):ind_en(i),4),...
                                        traj_bin(ind_be(i):ind_en(i),5),...
                                        traj_bin(ind_be(i):ind_en(i),20));
                                    
                                    
                                    
                                    % draw parent end
                                    scatter3(xp,yp,zps,10,'r');
                                    % draw child beg
                                    scatter3(xc,yc,zcs,20,'g','filled');
                                    % draw line parent-child
                                    plot3([xp xc],[yp yc],[zps zcs],'c')
                                    
                                    
                                    
                                    
                                end
                            else
                                
                                scale=((traj_bin(ind_be(ind_time(ind_begin(k))),4)-traj_bin(ind_en(ind_time(ind_begin(k))),4))^2+...
                                    (traj_bin(ind_be(ind_time(ind_begin(k))),5)-traj_bin(ind_en(ind_time(ind_begin(k))),5))^2+...
                                    (traj_bin(ind_be(ind_time(ind_begin(k))),6)-traj_bin(ind_en(ind_time(ind_begin(k))),6))^2)^0.5;
                                %now check if this new trajectory is long enough
                                %as measured in distance, not in terms of time
                                if abs(ind_time(ind_begin(k))-i)>0 & scale>min_scale && used(ind_time(ind_begin(k)))==0
                                    % and now FINALLY, again check if drop is large enough
                                    % i.e. check again whether drop between traj end and begin of new traj large enough?
                                    % above it was ind=find(list(:,3)-list(:,4)>accuracy(4));
                                    totalpix=zeros(len(ind_time(ind_begin(k))),1);
                                    for l=1:len(ind_time(ind_begin(k)))
                                        totalpix(l)=traj_bin(ind_be(ind_time(ind_begin(k)))+l-1,7);
                                    end
                                    list(ind(j),4)=mean(totalpix(1:max_jump));
                                    if list(ind(j),3)-list(ind(j),4)>accuracy(4)
                                        %%%%found breakage!!!!!!!!!!!!!!!!!
                                        %%%%found breakage!!!!!!!!!!!!!!!!!
                                        %%%%found breakage!!!!!!!!!!!!!!!!!
                                        
                                        % render stuff
                                        figure(fig_id);hold on;
                                        xp=traj_bin(ind_be(i)+list(ind(j),1)-1,4);
                                        yp=traj_bin(ind_be(i)+list(ind(j),1)-1,5);
                                        zp=traj_bin(ind_be(i)+list(ind(j),1)-1,7);
                                        zps=traj_bin(ind_be(i)+list(ind(j),1)-1,20);
                                        xc=vec_be(ind_time(ind_begin(k)),1);
                                        yc=vec_be(ind_time(ind_begin(k)),2);
                                        zc=totalpix_be(ind_time(ind_begin(k)));
                                        used(ind_time(ind_begin(k)))=1;
                                        zcs=strain_be(ind_time(ind_begin(k)));
                                        
                                        % draw parent end
                                        scatter3(xp,yp,zp,10,'r');
                                        % draw child beg
                                        scatter3(xc,yc,zc,20,'g','filled');
                                        % draw line parent-child
                                        plot3([xp xc],[yp yc],[zp zc],'c')
                                        
                                        %                                 if(ind_be(i)+list(ind(j),2)<ind_en(i))
                                        %                                     scatter3(traj_bin(ind_be(i)+list(ind(j),2)-1,4),traj_bin(ind_be(i)+list(ind(j),2)-1,5),list(ind(j),4),20,'g','filled');
                                        % %                                     totalpix_child=[totalpix_child;list(ind(j),4)];
                                        %                                 end
                                        
                                        % clean totalpix figure
                                        figure(100+fig_id);hold on;title('total pix')
                                        % draw parent traj
                                        plot3(traj_bin(ind_be(i):ind_en(i),4),...
                                            traj_bin(ind_be(i):ind_en(i),5),...
                                            traj_bin(ind_be(i):ind_en(i),7));
                                        
                                        break_pos=[break_pos;xp,yp,traj_bin(ind_be(i)+list(ind(j),1)-1,6),zp,zps,traj_bin(ind_be(i)+list(ind(j),1)-1,1),traj_bin(ind_be(i)+list(ind(j),1)-1,21),traj_bin(ind_be(i)+list(ind(j),1)-1,22),traj_bin(ind_be(i)+list(ind(j),1)-1,23),traj_bin(ind_be(i)+list(ind(j),1)-1,24),traj_bin(ind_be(i)+list(ind(j),1)-1,27),traj_bin(ind_be(i)+list(ind(j),1)-1,28),i,traj_bin(ind_be(i)+list(ind(j),1)-1,29),traj_bin(ind_be(i)+list(ind(j),1)-1,25),traj_bin(ind_be(i)+list(ind(j),1)-1,26)];
                                        unbreak_pos_par=[unbreak_pos_par;traj_bin(ind_be(i):ind_en(i),4),traj_bin(ind_be(i):ind_en(i),5),traj_bin(ind_be(i):ind_en(i),6),traj_bin(ind_be(i):ind_en(i),7),traj_bin(ind_be(i):ind_en(i),20),traj_bin(ind_be(i):ind_en(i),1),traj_bin(ind_be(i):ind_en(i),21),traj_bin(ind_be(i):ind_en(i),22),traj_bin(ind_be(i):ind_en(i),23),traj_bin(ind_be(i):ind_en(i),24),traj_bin(ind_be(i):ind_en(i),27),traj_bin(ind_be(i):ind_en(i),28),i*ones(length(traj_bin(ind_be(i):ind_en(i),4)),1),traj_bin(ind_be(i):ind_en(i),29),traj_bin(ind_be(i):ind_en(i),25),traj_bin(ind_be(i):ind_en(i),26)];
                                        
                                        
                                        % draw child traj
                                        plot3(traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),4),...
                                            traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),5),...
                                            traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),7));
                                        % draw parent end
                                        scatter3(xp,yp,zp,10,'r');
                                        % draw child beg
                                        scatter3(xc,yc,zc,20,'g','filled');
                                        % draw line parent-child
                                        plot3([xp xc],[yp yc],[zp zc],'c')
                                        
                                        
                                        unbreak_pos_child=[unbreak_pos_child;traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),4),traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),5),traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),6),traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),7),traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),20),traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),1),traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),21),traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),22),traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),23),traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),24),traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),27),traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),28),i*ones(length(traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),4)),1),traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),29),traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),25),traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),26)];
                                        start_child=[start_child;xc,yc,vec_be(ind_time(ind_begin(k)),3),zc,strain_be(ind_time(ind_begin(k))),frame_be(ind_time(ind_begin(k))),lambda1_be(ind_time(ind_begin(k))),lambda2_be(ind_time(ind_begin(k))),lambda3_be(ind_time(ind_begin(k))),gradmeas_be(ind_time(ind_begin(k))),size_meas1_be(ind_time(ind_begin(k))),size_meas2_be(ind_time(ind_begin(k))),i,grv_be(ind_time(ind_begin(k))),xpx_be(ind_time(ind_begin(k))),ypx_be(ind_time(ind_begin(k)))];
                                        
                                        %clean strain figure
                                        figure(200+fig_id);hold on;title('strain')
                                        % draw parent traj
                                        plot3(traj_bin(ind_be(i):ind_en(i),4),...
                                            traj_bin(ind_be(i):ind_en(i),5),...
                                            traj_bin(ind_be(i):ind_en(i),20));
                                        % draw child traj
                                        plot3(traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),4),...
                                            traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),5),...
                                            traj_bin(ind_be(ind_time(ind_begin(k))):ind_en(ind_time(ind_begin(k))),20));
                                        % draw parent end
                                        scatter3(xp,yp,zps,10,'r');
                                        % draw child beg
                                        scatter3(xc,yc,zcs,20,'g','filled');
                                        % draw line parent-child
                                        plot3([xp xc],[yp yc],[zps zcs],'c')
                                        
                                        % do stats
                                        % break pos, size, strain etc
                                        % num_child
                                        % child size
                                        
                                        
                                        
                                    end
                                    %%%%end of found breakage!!!!!!!!!!!!!!!!!
                                    %%%%end of found breakage!!!!!!!!!!!!!!!!!
                                    %%%%end of found breakage!!!!!!!!!!!!!!!!!
                                end
                            end
                        end
                    end
                end
                %%this completes the story a particular potential breakage
                %             %here we can do some statistics
                %             if length(totalpix_child)>1
                %                 global_totalpix_before = [global_totalpix_before;totalpix_before];
                %                 tmp=zeros(1,10);
                %                 tmp(1,1:length(totalpix_child))=totalpix_child';
                %                 global_totalpix_child  = [global_totalpix_child;tmp];
                %                 global_breakage_pos    = [global_breakage_pos;...
                %                     [traj_bin(ind_be(i)+list(ind(j),1)-1,4) traj_bin(ind_be(i)+list(ind(j),1)-1,5) traj_bin(ind_be(i)+list(ind(j),1)-1,6)]];
                %             end
            end
        end
        
        
%             if exist(['Result_unfiltered_v7\',foll{globi}])==0
%             mkdir(['Result_unfiltered_v7\',foll{globi}]);
%             end
%         
%             break_pos = unique(break_pos, 'rows');
%             unbreak_pos_par = unique(unbreak_pos_par,'rows');
%             unbreak_pos_child = unique(unbreak_pos_child,'rows');
%             start_child = unique(start_child,'rows');
%             save(['Result_unfiltered_v7/',foll{globi},'break_pos_',ar(fig_id).name],'break_pos','unbreak_pos_par','unbreak_pos_child','start_child')
%         %
%         
%             if size(unbreak_pos_par,1)>0
%             indd=find(unbreak_pos_par(:,10)<=0.2);
%             unbreak_pos_par=unbreak_pos_par(indd,:);
%             end
%         
%             if size(unbreak_pos_child,1)>0
%             indd_2=find(unbreak_pos_child(:,10)<=0.2);
%             unbreak_pos_child=unbreak_pos_child(indd_2,:);
%             end
%         
%             if exist(['Result_filtered_0p2_v7\',foll{globi}])==0
%             mkdir(['Result_filtered_0p2_v7\',foll{globi}]);
%             end
%             save(['Result_filtered_0p2_v7/',foll{globi},'break_pos_',ar(fig_id).name],'break_pos','unbreak_pos_par','unbreak_pos_child','start_child')
        
        
        
    end
    % here the loop through all trajectories is completed
    
end





% save stats global_totalpix_before global_totalpix_child global_breakage_pos

% figure;scatter3(global_breakage_pos(:,1),global_breakage_pos(:,2),global_breakage_pos(:,3))
%
% figure;hist(global_totalpix_before)
% xlabel('totalpix before')
%
% ind=find(global_totalpix_child>0);
% figure;hist(global_totalpix_child(ind))
% xlabel('totalpix children')
%
% si=size(global_totalpix_child);
% for i=1:si(1,1)
%    ind=find(global_totalpix_child(i,:)>0);
%    howmany(i)=length(ind);
% end
% figure;hist(howmany)
% xlabel('# children')
%
% figure;scatter(global_totalpix_before,howmany)
% xlabel('totalpix before')
% ylabel('# children')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%FUNCTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function num_in_traj=init_traj(i,j)

global traj;

traj=[0 0];
traj(1,1)=i;
traj(1,2)=j;
num_in_traj=1;

function num_in_traj=find_next(num_in_traj,columns,first,last)

global traj;
global ptv;

i=traj(num_in_traj,1);
j=traj(num_in_traj,2);
if i<last-first+1
    if ptv(i,j,2)>-1 & ptv(i+1,ptv(i,j,2)+1,columns+1)==0
        num_in_traj=num_in_traj+1;
        traj(num_in_traj,1)=i+1;
        traj(num_in_traj,2)=ptv(i,j,2)+1;%% C -> Matlab
    end
end

function vec_be_proj=proj_be_to_en(vec_be,ind_time,ind_be,ind_en,max_jump,proj_frame)

global traj_bin;

vec_be_proj=[];
order=2;

for i=1:length(ind_time)
    A=zeros(max_jump+1,order+1);
    y=zeros(max_jump+1,order+1);
    count=0;
    for frame=traj_bin(ind_be(ind_time(i)),1):traj_bin(ind_be(ind_time(i)),1)+max_jump
        count=count+1;
        for or=0:order
            A(count,or+1)=frame^or;
        end
        for n=1:3
            y(count,n)=traj_bin(ind_be(ind_time(i))+count-1,3+n);
        end
    end
    X=(A'*A)\A'*y;
    
    %loop through jump size until max jump is reached
    proj=[];
    for n=1:n
        proj(n)=0;
        for or=0:order
            proj(n)=proj(n)+X(or+1,n)*proj_frame^or;
        end
    end
    vec_be_proj=[vec_be_proj;proj];
end



function go=glue_traj(max_jump,start_frame,first,last,columns,tol)

global traj;
global ptv;

global log;

global eps;
global gluedim;

global tot_glues;
global suc_jump;

for i=1:length(gluedim)
    accuracy(i)=eps(gluedim(i));%[dx dy dz d_totalpix];
end

si=size(traj);
%determine order, which is used to attempt gluing jump
order=floor(si(1,1)/4)-1;
if order<0
    order=0;
end
if order>2
    order=2;
end

%prepare polynomial fit for jumps
en=si(1,1);
be=en-max_jump;
if be<1
    be=1;
end
be=be+start_frame-1;
en=en+start_frame-1;

A=zeros(en-be+1,order+1);
y=zeros(en-be+1,length(gluedim));
count=0;
for frame=be:en
    count=count+1;
    for or=0:order
        A(count,or+1)=frame^or;
    end
    i=traj(frame-start_frame+1,1);
    j=traj(frame-start_frame+1,2);
    for n=1:length(gluedim)%3:6
        y(count,n)=ptv(i,j,gluedim(n));
    end
end
if det(A'*A)>1e-15
    X=(A'*A)\A'*y;
    nogo=0;
else
    nogo=1;
end

%loop through jump size until max jump is reached

if nogo==0
    for jump=1:max_jump
        %jump and check in n-dim space whether anything is
        %close enough or not, i.e. x,u?,size?
        frame=en+jump;
        if frame>last-first+1
            go=0;
            break;
        end
        %howmany points in frame n?
        ind=find(ptv(frame,:,1)>-10);
        num_part=length(ind);
        proj=[];
        for n=1:length(gluedim)%3:6
            proj(n)=0;
            for or=0:order
                proj(n)=proj(n)+X(or+1,n)*frame^or;
            end
        end
        proj=repmat(proj,num_part,1);
        acc=repmat(accuracy,num_part,1);
        if num_part>1
            dist=(proj-squeeze(ptv(frame,1:num_part,gluedim)))./acc;
        else %%%fix for unwanted transposed
            dist=(proj-squeeze(ptv(frame,1:num_part,gluedim))')./acc;
        end
        %exclude those canditates, which are already part of another trajectory
        ind_occ=find(ptv(frame,1:num_part,columns+1)==1);
        dist=sum(dist.^2,2).^0.5;
        dist(ind_occ)=1e9;
        mini=min(dist);
        ind=find(dist==mini);
        if length(ind)>0 & mini<tol*sqrt(length(gluedim)) & length(mini) > 0
            %if close enough create new points in gap etc...
            go=1;
            tot_glues=tot_glues+1;
            suc_jump=jump;
            log=[log;[en en+jump jump]];
            %create points in-betwen
            i=traj(en-start_frame+1,1);
            j=traj(en-start_frame+1,2);
            j_ar(1)=j;
            j_ar(jump+1)=ind;
            p_g(1,1:columns)=squeeze(ptv(i,j,1:columns))';
            p_g(jump+1,1:columns)=squeeze(ptv(frame,ind,1:columns))';
            for fr=en+1:en+jump-1
                %howmany points in frame fr?
                ind=find(ptv(fr,:,1)>-10);
                num_part=length(ind);
                j_ar(fr-en+1)=num_part+1;
                w_e=(fr-en)/jump;
                w_b=1-w_e;
                p_g(fr-en+1,1:columns)=w_b*p_g(1,1:columns)+w_e*p_g(jump+1,1:columns);
            end
            %update ptv array
            ptv(en,j_ar(1),2)=j_ar(2)-1;
            for fr=2:jump
                ptv(en+fr-1,j_ar(fr),1:columns)=p_g(fr,1:columns);
                if fr>1 & fr<jump+1
                    ptv(en+fr-1,j_ar(fr),1)=j_ar(fr-1)-1;
                    ptv(en+fr-1,j_ar(fr),2)=j_ar(fr+1)-1;
                end
            end
            ptv(en+jump,j_ar(jump+1),1)=j_ar(jump)-1;
 
            break; %%breaks of for loop through jump
        else
            go=0;
        end
    end
end

function res=plot_traj(fig_id,time)

global traj;
global traj_bin;
global ptv;

figure(fig_id); hold on;
for i=1:length(traj)
    x(i)=ptv(traj(i,1),traj(i,2),23);
    y(i)=ptv(traj(i,1),traj(i,2),24);
    z(i)=ptv(traj(i,1),traj(i,2),25);
    
    totalpix(i)=ptv(traj(i,1),traj(i,2),6);
    xpx(i)=ptv(traj(i,1),traj(i,2),7);
    ypx(i)=ptv(traj(i,1),traj(i,2),8);
    sumgrv(i)=ptv(traj(i,1),traj(i,2),9);
    
    m_u(i)= ptv(traj(i,1),traj(i,2),10);
    m_v(i)= ptv(traj(i,1),traj(i,2),11);
    m_w(i)= ptv(traj(i,1),traj(i,2),12);
    m_vel(i)= ptv(traj(i,1),traj(i,2),13);
    ux(i)= ptv(traj(i,1),traj(i,2),14);
    uy(i)= ptv(traj(i,1),traj(i,2),15);
    uz(i)= ptv(traj(i,1),traj(i,2),16);
    vx(i)= ptv(traj(i,1),traj(i,2),17);
    vy(i)= ptv(traj(i,1),traj(i,2),18);
    vz(i)= ptv(traj(i,1),traj(i,2),19);
    wx(i)= ptv(traj(i,1),traj(i,2),20);
    wy(i)= ptv(traj(i,1),traj(i,2),21);
    wz(i)= ptv(traj(i,1),traj(i,2),22);
    strain(i)= ptv(traj(i,1),traj(i,2),26);
    lambda1(i)= ptv(traj(i,1),traj(i,2),27);
    lambda2(i)= ptv(traj(i,1),traj(i,2),28);
    lambda3(i)= ptv(traj(i,1),traj(i,2),29);
    grad_meas(i)= ptv(traj(i,1),traj(i,2),30);
    size_meas1(i)= ptv(traj(i,1),traj(i,2),31);
    size_meas2(i)= ptv(traj(i,1),traj(i,2),32);
    
    
    id(i)=i;
    frame_i(i)=traj(i,1);
    j(i)=traj(i,2);
end
ok=1;

if 1<2 %min(x)<0.01
    plot3(x,y,totalpix,'b');
    %scatter3(x,y,z,5,totalpix);
    traj_bin=[traj_bin; [frame_i' j' id' x' y' z' totalpix' m_u' m_v' m_w' ux' uy' uz' vx' vy' vz' wx' wy' wz' strain' lambda1' lambda2' lambda3' grad_meas',xpx',ypx',size_meas1',size_meas2',sumgrv']];%%%%%%%%%%%%%%%%%%%%%
end

% figure(fig_id+1); hold on;
% if length(traj)>3 & min(x)<0.01
%     scatter3(x,y,z,5,xpx);
% end
% figure(fig_id+2); hold on;
% if length(traj)>3 & min(x)<0.01
%     scatter3(x,y,z,5,ypx);
% end
% figure(fig_id+3); hold on;
% if length(traj)>3 & min(x)<0.01
%     scatter3(x,y,z,5,sumgrv);
% end

function res=update(columns)

global traj;
global ptv;

for i=1:length(traj)
    ptv(traj(i,1),traj(i,2),columns+1)=1;
end

function ptv=filter_traj()

global traj;
global ptv;

for i=1:length(traj)
    if i==1
        nx(i)=0.5*ptv(traj(i,1),traj(i,2),3)+0.5*ptv(traj(i+1,1),traj(i+1,2),3);
        ny(i)=0.5*ptv(traj(i,1),traj(i,2),4)+0.5*ptv(traj(i+1,1),traj(i+1,2),4);
        nz(i)=0.5*ptv(traj(i,1),traj(i,2),5)+0.5*ptv(traj(i+1,1),traj(i+1,2),5);
        
        
        ntot_pix(i)=0.5*ptv(traj(i,1),traj(i,2),6)+0.5*ptv(traj(i+1,1),traj(i+1,2),6);
        nx_pix(i)=0.5*ptv(traj(i,1),traj(i,2),7)+0.5*ptv(traj(i+1,1),traj(i+1,2),7);
        ny_pix(i)=0.5*ptv(traj(i,1),traj(i,2),8)+0.5*ptv(traj(i+1,1),traj(i+1,2),8);
        ngrv(i)=0.5*ptv(traj(i,1),traj(i,2),9)+0.5*ptv(traj(i+1,1),traj(i+1,2),9);
        
    end
    if i==length(traj)
        nx(i)=0.5*ptv(traj(i,1),traj(i,2),3)+0.5*ptv(traj(i-1,1),traj(i-1,2),3);
        ny(i)=0.5*ptv(traj(i,1),traj(i,2),4)+0.5*ptv(traj(i-1,1),traj(i-1,2),4);
        nz(i)=0.5*ptv(traj(i,1),traj(i,2),5)+0.5*ptv(traj(i-1,1),traj(i-1,2),5);
        
        
        ntot_pix(i)=0.5*ptv(traj(i,1),traj(i,2),6)+0.5*ptv(traj(i-1,1),traj(i-1,2),6);
        nx_pix(i)=0.5*ptv(traj(i,1),traj(i,2),7)+0.5*ptv(traj(i-1,1),traj(i-1,2),7);
        ny_pix(i)=0.5*ptv(traj(i,1),traj(i,2),8)+0.5*ptv(traj(i-1,1),traj(i-1,2),8);
        ngrv(i)=0.5*ptv(traj(i,1),traj(i,2),9)+0.5*ptv(traj(i-1,1),traj(i-1,2),9);
    end
    if i>1 & i<length(traj)
        order=min(i-1,length(traj)-i);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if order>4
            order=4;
        end
        switch order
            case 1
                weight=[2 1];
            case 2
                weight=[6 4 1];
            case 3
                weight=[20 15 6 1];
            case 4
                weight=[70 56 28 8 1];
                
            case 5
                 weight=[252 210 120 45 10 1];
                 
            case 6
                 weight=[924 792 495 220 66 12 1];
                 
            case 7
                weight=[3432,3003,2002,1001,364,91,14,1];
                
             case 8
                weight=[12870,11440,8008,4368,1820,560,120,16,1];
            case 9
                weight=[48620,43758,31824,18564,8568,3060,816,153,18,1];
            case 10
                weight=[184756,167960,125970,77520,38760,15504,4845,1140,190,20,1];
             case 11  
                weight=[705432,646646,497420,319770,170544,74613,26334,7315,1540,231,22,1];
            case 12
                weight=[2704156,2496144,1961256,1307504,735471,346104,134596,42504,10626,2024,276,24,1];
  
            case 13
                weight=[10400600,9657700,7726160,5311735,3124550,1562275,657800,230230,65780,14950,2600,325,26,1];
        
            case 14
                weight=[40116600,37442160,30421755,21474180,13123110,6906900,3108105,1184040,376740,98280,20475,3276,378,28,1];
        
            case 15
                weight=[155117520,145422675,119759850,86493225,54627300,30045015,14307150,5852925,2035800,593775,142506,27405,4060,435,30,1];
                
            case 16
                weight=[601080390,565722720,471435600,347373600,225792840,129024480,64512240,28048800,10518300,3365856,906192,201376,35960,4960,496,32,1];
                
            case 17
                weight=[2333606220.00000,2203961430.00000,1855967520.00000,1391975640.00000,927983760,548354040,286097760,131128140,52451256,18156204,5379616,1344904,278256,46376,5984,561,34,1];
            case 18
                weight=[9075135300.00000,8597496600.00000,7307872110.00000,5567902560.00000,3796297200.00000,2310789600.00000,1251677700.00000,600805296,254186856,94143280,30260340,8347680,1947792,376992,58905,7140,630,36,1];
            case 19
                weight=[35345263800.0000,33578000610.0000,28781143380.0000,22239974430.0000,15471286560.0000,9669554100.00000,5414950296.00000,2707475148.00000,1203322288.00000,472733756,163011640,48903492,12620256,2760681,501942,73815,8436,703,38,1];
            case 20
                weight=[137846528820.000,131282408400.000,113380261800.000,88732378800.0000,62852101650.0000,40225345056.0000,23206929840.0000,12033222880.0000,5586853480.00000,2311801440.00000,847660528,273438880,76904685,18643560,3838380,658008,91390,9880,780,40,1];
        end
        su=0;
        fx=0;fy=0;fz=0;ftotpix=0;fxpix=0;fypix=0;fgrv=0;
        for j=i-order:i+order
            su=su+weight(abs(i-j)+1);
            fx=fx+ptv(traj(j,1),traj(j,2),3)*weight(abs(i-j)+1);
            fy=fy+ptv(traj(j,1),traj(j,2),4)*weight(abs(i-j)+1);
            fz=fz+ptv(traj(j,1),traj(j,2),5)*weight(abs(i-j)+1);
            
            ftotpix=ftotpix+ptv(traj(j,1),traj(j,2),6)*weight(abs(i-j)+1);
            fxpix=fxpix+ptv(traj(j,1),traj(j,2),7)*weight(abs(i-j)+1);
            fypix=fypix+ptv(traj(j,1),traj(j,2),8)*weight(abs(i-j)+1);
            fgrv=fgrv+ptv(traj(j,1),traj(j,2),9)*weight(abs(i-j)+1);
            
            
        end
        nx(i)=fx/su;
        ny(i)=fy/su;
        nz(i)=fz/su;
        
        ntot_pix(i)=ftotpix/su;
        nx_pix(i)=fxpix/su;
        ny_pix(i)=fypix/su;
        ngrv(i)=fgrv/su;
        
        
        
        
    end
end

for i=1:length(traj)
    ptv(traj(i,1),traj(i,2),3)=nx(i);
    ptv(traj(i,1),traj(i,2),4)=ny(i);
    ptv(traj(i,1),traj(i,2),5)=nz(i);
    
    ptv(traj(i,1),traj(i,2),6)=ntot_pix(i);
    ptv(traj(i,1),traj(i,2),7)=nx_pix(i);
    ptv(traj(i,1),traj(i,2),8)=ny_pix(i);
    ptv(traj(i,1),traj(i,2),9)=ngrv(i);
    
    
end






