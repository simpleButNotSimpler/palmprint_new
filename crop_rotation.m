function [row, col, im_out] = crop_rotation(gray_im)
    %convert image to binary
    bw_im = gray_im > 0;
    
    %apply convexhull
    bw_im = bwconvhull(bw_im);
    
    [row, col] = size(bw_im);
    
    center = round(row/2);
    row_start = center;
    row_end = center;
    col_start = center;
    col_end = center;
    
    stop = 0;
    while 1
        row_start = row_start - 1;
        row_end = row_end + 1;
        col_start = col_start - 1;
        col_end = col_end + 1;
        
        try
            temp = bw_im(row_start:row_end, col_start:col_end);
        catch
            stop = 1;
        end
        
        if ~all(temp(:))
            stop = 1;            
        end
        
        if stop
            row(1) = row_start+1+5;
            row(2) = row_end-1-5;            
            col(1) = col_start+1+5;
            col(2) = col_end-1-5;
            im_out = gray_im(row(1):row(2), col(1):col(2));
            break
        end
    end
    
end