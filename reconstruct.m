[cam1FileList, cam2FileList, cam3FileList] = readFileList('FileList.csv');

% Each iteration is a different ping pong serving event
for i = 1 : size(cam1FileList)
    [cam1Annot, cam2Annot, cam3Annot] = ...
        readAnnotations(cam1FileList(i), cam2FileList(i), cam3FileList(i));

    trajectory = zeros(length(cam1Annot), 3);
    for j = 1 : length(cam1Annot)
        trajectory(j,:) = compute3d(cam1Annot(j,:), ...
                                    cam2Annot(j,:), ...
                                    cam3Annot(j,:));
    end
    trajectory(ismember(trajectory,[-999,-999,-999], 'rows'),:) = [];
    csvwrite(strcat('s', int2str(i),'.csv'), trajectory);
    
    %Remove this to run for all events ie 10 different videos
    keyboard
end

function coordinates = compute3d(cam1ImgPt, cam2ImgPt, cam3ImgPt) 
    % Computing A of Ax = 0. Minimum 2 cameras
    A = [];
    if (~isequal(cam1ImgPt, [0 0]))
        A = [A; computeComponent(1, cam1ImgPt(1), cam1ImgPt(2))];

    end
    if (~isequal(cam2ImgPt, [0 0]))
        A = [A; computeComponent(2, cam2ImgPt(1), cam2ImgPt(2))];
    end
    if (~isequal(cam3ImgPt, [0 0]))
        A = [A; computeComponent(3, cam3ImgPt(1), cam3ImgPt(2))];
    end
    
    [row,~] = size(A);
    if (row > 3) % If there is at least 2 cameras
        [~,~,V] = svd(A);
        coordinates = V(:,end);
        coordinates = transpose(coordinates(1:end-1));
    else
        coordinates = [-999, -999, -999];
    end
end

function a = computeComponent(camNum, u, v)
    u = u - 1920/2;
    v = v - 1080/2;
    
    R1 = [9.6428667991264605e-01  -2.6484969138677328e-01 -2.4165916859785336e-03;
    -8.9795446022112396e-02 -3.1832382771611223e-01 -9.4371961862719200e-01;
    2.4917459103354755e-01 9.1023325674273947e-01 -3.3073772313234923e-01];

    R2 = [9.4962278945631540e-01 3.1338395965783683e-01 -2.6554800661627576e-03;
    1.1546856489995427e-01 -3.5774736713426591e-01 -9.2665194751235791e-01;
    -2.9134784753821596e-01 8.7966318277945221e-01 -3.7591104878304971e-01];

    R3 = [-9.9541881789113029e-01 3.8473906154401757e-02  -8.7527912881817604e-02; 
    9.1201836523849486e-02 6.5687400820094410e-01 -7.4846426926387233e-01;
    2.8698466908561492e-02 -7.5301812454631367e-01 -6.5737363964632056e-01];

    AllR = {R1, R2, R3};

    t1 = [1.3305621037591506e-01; -2.5319578738559911e-01; 2.2444637695699150e+00];
    t1 = -inv(R1) * t1;
    t2 = [-4.2633372670025989e-02; -3.5441906393933242e-01; 2.2750378317324982e+00];
    t2 = -inv(R2) * t2;
    t3 = [-6.0451734755080713e-02; -3.9533167111966377e-01; 2.2979640654841407e+00];
    t3 = -inv(R3) * t3;
    
    Allt = {t1, t2, t3};

    intric1 = [8.7014531487461625e+02 0 9.4942001822880479e+02;
    0 8.7014531487461625e+02 4.8720049852775117e+02;
    0 0 1];

    intric2 = [8.9334367240024267e+02 0 9.4996816131377727e+02
    0 8.9334367240024267e+02 5.4679562177577259e+02
    0 0 1];

    intric3 = [8.7290852997159800e+02 0 9.4445161471037636e+02
    0 8.7290852997159800e+02 5.6447334036925656e+02
    0 0 1];

    AllIntric = {intric1, intric2, intric3};
    
    R = AllR{camNum};
    i = R(1,:);
    j = R(2,:);
    k = R(3,:);
    t = Allt{camNum};
    intric = AllIntric{camNum};
    fbu = intric(1);
    u0 = intric(1,end);
    fbv = intric(2,2);
    v0 = intric(2, end);
    c = (u - u0) / fbu;
    d = (v - v0) / fbv;
    
    a = [i(1)-c*k(1) i(2)-c*k(2) i(3)-c*k(3) ...
        c*t(1)*k(1)+c*t(2)*k(2)+c*t(3)*k(3)-t(1)*i(1)-t(2)*i(2)-t(3)*i(3);
        j(1)-d*k(1) j(2)-d*k(2) j(3)-d*k(3) ... 
        d*t(1)*k(1)+d*t(2)*k(2)+d*t(3)*k(3)-t(1)*j(1)-t(2)*j(2)-t(3)*j(3)];
end

function [a1, a2, a3] = readAnnotations(file1, file2, file3)
    cam1AnnotFile = strrep(strcat('Annotation/', file1), ".mp4", ".csv");
    cam2AnnotFile = strrep(strcat('Annotation/', file2), ".mp4", ".csv");
    cam3AnnotFile = strrep(strcat('Annotation/', file3), ".mp4", ".csv");
    
    a1 = csvread(cam1AnnotFile, 1, 3);
    a2 = csvread(cam2AnnotFile, 1, 3);
    a3 = csvread(cam3AnnotFile, 1, 3);
end


function [cam1, cam2, cam3] = readFileList(filename)
    fid = fopen(filename);
    files = textscan(fid, '%s%s%s', 'delimiter' , ',');
    fclose(fid);
    
    cam1 = files{1};
    cam2 = files{2};
    cam3 = files{3};
end