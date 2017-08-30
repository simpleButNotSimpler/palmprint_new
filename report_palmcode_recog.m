function report_palmcode_recog()
total = 0;
right_dp = zeros(1, 4);
wrong_dp = right_dp;
right_al = zeros(1, 1);
wrong_al = right_al;


%parpool
% parpool(4)

for main_counter=1:100
    disp(num2str(main_counter))
    im_prefix = strcat('p', num2str(main_counter), '_*.bmp');
    
    testim = dir(fullfile('data\testimages\cleaned', im_prefix));
    if isempty(testim)
       continue
    end
    
    if numel(testim) ~= 6
        disp('nou la')
    end
    
    %recognition
    for t=1:numel(testim)
       current_im_name = testim(t).name;
        
       %get class (1xN array), same size as error
       [dp] = report_score(current_im_name);
       
       %classification
       %min indexes
       [~, dp_min_idx] = min(dp);
%        [~, al_min_idx] = min(al);
       
       %verdicts
       idx = (dp_min_idx == main_counter);
       right_dp = right_dp + idx;
       wrong_dp = wrong_dp + ~idx;
       
       if ~idx(1)
          fid = fopen('mismatched_real_shrink.txt', 'a');
          fprintf(fid, '%10s %3d \n', current_im_name, dp_min_idx(1));
          fclose(fid);
       end
       
%        idx = (al_min_idx == main_counter);
%        right_al = right_al + idx;
%        wrong_al = wrong_al + ~idx;
       
       total = total + 1;
    end
 end

%write result to file
% fid = fopen('recog_palmcode_without_al.txt', 'w');
% fprintf(fid, '%s \n%12s %20s %20s \n', 'DP', 'dc_orig_min', 'dc_palmregion_min', 'cleaned_orig_min');
% fprintf(fid, '%12d %20d %20d\n', [right_dp, wrong_dp]);
% 
% fprintf(fid, '%s \n%12s %10s %16s %14s %8s %7s\n', 'AL',...
%              'dc_full_rot', 'dc_cr_rot', 'dc_pr_full_rot', 'dc_pr_cr_rot', 'cl_rot', 'cl_pr');
% fprintf(fid, '%12d %10d %16d %14d %8d %7d\n', [right_al, wrong_al]);
% fprintf(fid, '\nTOTAL = %d\n', total);

% fid = fopen('recog_palmcode_without_al.txt', 'w');
% fprintf(fid, '%s \n%12s %20s \n', 'DP', 'dc_orig_min', 'dc_palmregion_min');
% fprintf(fid, '%12d %20d\n', [right_dp, wrong_dp]);

fid = fopen('recog_palmcode_without_al.txt', 'w');
fprintf(fid, '%s \n%5s %5s %5s %5s \n', 'shrink', 's1', 's2', 's3', 's4');
fprintf(fid, '%5d %5d %5d %5d\n', [right_dp, wrong_dp]);

fprintf(fid, '\n%s \n%8s\n', 'AL', 'cl_rot');
fprintf(fid, '%8d\n', [right_al, wrong_al]);
fprintf(fid, '\nTOTAL = %d\n', total);

fclose(fid);

% delete(gcp('nocreate'))
disp('nou fini')
end


function [score] = report_score(im_test_name)
   %image
   
   %test the image against all the database
%    folder_cleaned = 'data\database\cleaned';
   folder_dc = 'data\database\direction_code';
   dp = zeros(500, 2) + inf;
%    al = zeros(500, 1) + inf;
   
   for t=1:500
       db_name = strcat('db', num2str(t),'_*.bmp');
%        database_cleaned = dir(fullfile(folder_cleaned, db_name));
       database_dc = dir(fullfile(folder_dc, db_name));
       
       %get the score form direct palmcode 
%        dp(t, :) = direct_palmcode(im_test_name, database_dc);
       score(t, :) = direct_palmcode_shrink(im_test_name, database_dc);
       
       
       %get the score from aligned palmcode
%        al(t, :) = aligned_palmcode(im_test_name, database_cleaned);
   end
end