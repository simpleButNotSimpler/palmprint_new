function report_palmcode_recog_with_al()
total = 0;
right = 0;
wrong = right;

for main_counter=1:185 
    disp(num2str(main_counter))
    im_prefix = strcat('p', num2str(main_counter));
    
    testim = dir(strcat('data\testimages\direction_code\', im_prefix, '_*.bmp'));
    if isempty(testim)
       continue
    end
    
    if numel(testim) ~= 5
        disp('nou la')
    end
    
    %recognition
    for t=1:numel(testim)
       %get class (1xN array), same size as error
       [class, tann] = report_score(testim(t).folder, testim(t).name, main_counter, 0.3);
       
       if class
           right = right + 1;
       else
           wrong = wrong + 1;
       end
       
       total = total + 1;
       
       plot(1:numel(tann), tann, '*'), hold off
       saveas(gcf, strcat('data\palmcode_error_with_al\', 'p', num2str(main_counter), '_', num2str(t), '.bmp'))
    end
 end

%write result to file
fid = fopen('recog_palmcode_with_al.txt', 'w');
fprintf(fid, '%6s %6s %6s\n', 'Right', 'Wrong', 'Total');
fprintf(fid, '%6d %6d %6d\n', right, wrong, total);
fclose(fid);

disp('nou fini')
end


function [class, tann] = report_score(test_im_folder, test_im_name, main_counter, error)
   %image
   test_im = imread(fullfile(test_im_folder, test_im_name));
   class = 0;
   monte = 1;
   witness = 1;
   aligned = 0;
   
   if isempty(find(test_im, 1))
       class = 0;
       return
   end
   
   for t=1:185
       if t == main_counter
         aligned = 1;
       end
       
       db_prefix = strcat('db', num2str(t));
       sub_database = dir(strcat('data\database\direction_code\', db_prefix, '_*.bmp'));
       
       for sub_counter=1:numel(sub_database)
           db_im_name = sub_database(sub_counter).name;
           current_dbim = imread(fullfile(sub_database(sub_counter).folder, sub_database(sub_counter).name));

           %score = palm_histo_score(test_im, current_dbim);
           score = get_palmcode_error(test_im, current_dbim, test_im_name, db_im_name, error, aligned);
           aligned = 0;
           tann(monte) = score;
           monte = monte +1;
           
           if (score <= error) && witness
              witness = 0;
              if t == main_counter
                 class = 1;
              end
           end
           
       end
   end
end

% function [winner_idx, gloabl_min, witness] = build_alignment_one(moving_im, database)
% db_len = length(database);
% witness = 0;
% winner_idx = 1;
% 
% gloabl_min = inf;
% 
% for counter=1:db_len
%     % get the image image for one person
%     fixed_im = imread(fullfile(database(counter).folder, database(counter).name));
%     
%     if isempty(find(fixed_im, 1))
%         continue
%     end
%     
%     witness = 1;
%     
%     score = palm_histo_score(moving_im, fixed_im);
%     %global_min
%     if score < gloabl_min
%         winner_idx = counter;
%         gloabl_min = score;
%     end 
% end
% 
% end