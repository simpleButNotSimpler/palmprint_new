function score = palmline_diff(set1, set2)
    set1 = round(set1) + 100;
    set2 = round(set2) + 100;
    
    %get the max size
    row = max([set1(2, :), set2(2, :)]) + 1;
    col = max([set1(1, :), set2(1, :)]) + 1;
    
    im1 = zeros(row, col);
    im2 = im1;
    
    idx1 = sub2ind([row, col], set1(2, :), set1(1, :));
    idx2 = sub2ind([row, col], set2(2, :), set2(1, :));
    
    im1(idx1) = 1;
    im2(idx2) = 1;
    
    % get the score of the images
    s_ab = matching_score(im1, im2);
    s_ba = matching_score(im2, im1);

    score = max(s_ab, s_ba);
end

function score = matching_score(test, db)
    [row, col] = find(test);
    score = 0;
    
    len = numel(row);
    for t=1:len
        x = row(t);
        y = col(t);
        score = score + (db(x,y) | db(x+1,y) | db(x-1,y) | db(x,y+1) | db(x, y-1));
    end
    
    score = score/len;
end