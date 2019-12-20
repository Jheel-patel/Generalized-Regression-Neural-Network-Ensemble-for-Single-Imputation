
clc;
clear;
warning off;

%INPUT THE PATH TO INCOMPLETE DATASET
dataset_path='J:\Windsor University\Summer 2019\Data Mining\Poject\Course Project Datasets (1)\Incomplete Datasets Without Labels\DERM\'; 

%INPUT THE PATH TO OUTPUT DIRECTORY
output_dir = 'J:\Windsor University\Summer 2019\Data Mining\Poject\Course Project Datasets (1)\Imputed Datasets\DERM\';
list= dir([dataset_path,'DERM_C_10.xlsx']);%'*" means -select all excel files; or you can enter a specific filename

%READ THE ORIGINAL DATASET
[orig_dataset,orig_txt,orig_raw]= xlsread('J:\Windsor University\Summer 2019\Data Mining\Poject\Course Project Datasets (1)\Original Datasets Without Labels\DERM.xlsx');
[size_row,size_col]=size(orig_dataset);    
%TESTTING-for loop maynot work if the input directory location is incorrect
%below comand checks if my input path is correct or not, if the list is empty it wont work
if isempty(list)==1
   display("Incorrect input path; list is empty")
end

for counter=1:length(list)
    tic                                      % start the timer
    
    %READ INCOMOPLETE DATASET
    sprintf('%s%d','Loop Number:',counter);
    display([dataset_path,list(counter).name]); %display the dataset
    f = [list(counter).name];
    [dataset,txt,raw]= xlsread([dataset_path,list(counter).name]);%seprate the dataset, text and format
    
    flag='Small data';
    %ONLY FOR LARGE DATASETS-WE TRANSPOSE THE DATASET
    if (size_row*size_col)>15000
        dataset=dataset';
        flag='Large data';
    end
        
    %DEVELOP THE INDICATOR MATRIX
    indicator_matrix=isnan(dataset);
    
    %COUNT THE NUMBER OF MISSING VALUES
    n1=sum(indicator_matrix,'omitnan');
    n=sum(n1);
    
    %NORMALIZE THE INCOMPLETE DATASET
    Normalized_dataset=normalize(dataset,'range');
    
    %OBTAIN LOCATION OF EACH MISSING VALUE
    [row,col]=find(indicator_matrix==1);
    
    %LOOP UNTIL CONDITIONAL MEAN BECOMES LESS THAN 0.0001
    q=1;
    difference(1)=1;
    conditional_mean(1)=0;
    count=1;
    while difference(q)>0.1
            count=count+1;
            
            
            for q=2:count
                
                i=1;
                k=1;
                
                %COMPUTE THE COMPLETE DATASET (DELETE ROWS WITH MISSING VALUES)               
                complete_dataset=rmmissing(Normalized_dataset);
                
                %IF COMPLETE DATASET IS EMPTY , THEN FILL THE INCOMPLETE DATASET WITH NEAREST NEIGHBOUR
                if isempty(complete_dataset)==1 || size(complete_dataset,1)<20
                   complete_dataset=fillmissing(Normalized_dataset,'nearest');                    
                end  
                
                %COMPUTE EACH MISSING VALUE ONE BY ONE
                for i=1:n        
                    if k<=n
                        %WE CHOOSE THE MISSING VALUE IN FIRST ROW AND FIRST COLUMN
                                         
                        %CHECK THE NUMBER OF MISSING IN THE ROW CHOSEN
                        Temp_row=indicator_matrix(row(i),:);
                        [row1,col1]=find(Temp_row==1);
                        
                        %WE CHOSE THE COLUMN HAVING MISSING VALUE AS OUT OUTPUT COLUMN
                        Output=complete_dataset(:,col(i));
                        
                        %WE CHOSE THE COLUMNS OTHER THAN MISSING VALUE COLUMN AS OUR INPUT
                        complete_dataset2=complete_dataset;
                        complete_dataset2(:,col1)=[];
                        Input=complete_dataset2;
                        
                        %CHECK IF THERE ARE MORE THAN 10 FEATURES OR ITS A LARGE DATASET OR SMALL
                        if size(Input,2)>10
                            
                            %IF INPUT FEATURES ARE MORE THAN 10 , WE CHOOSE THE 10 BEST FEATURES USING RELIEFF ALGORITHM
                            nearest_neighbour=12;
                            [feature,weight]=relieff(Input,Output,nearest_neighbour);
                            [index1,index2]=find(feature);
                            Index_Matrix=[feature;index2];
                            Index_Matrix_sorted=sortrows(Index_Matrix.',1).';
                            if flag=='Large data'
                                Feature_col_location=Index_Matrix_sorted(:,1:500);
                            else
                                Feature_col_location=Index_Matrix_sorted(:,1:10);
                            end
                            Feature_location=Feature_col_location(2,:);
                            Input_Features=Input(:,Feature_location);
                            
                            
                            %TRAIN A GRNN USING THE INPUT AND OUTPUT
                            Grnn{i}=newgrnn(Input_Features',Output');
                            
                            %WE CHOOSE THE INPUT COLUMN FOR SIMULATING THE GRNN
                            Input_sim_temp=Normalized_dataset;
                            Input_sim_temp(:,col1)=[];
                            Input_sim_temp2=Input_sim_temp(:,Feature_location);
                            Input_sim=Input_sim_temp2(row(i),:);
                        else
                            
                            %IF INPUT FEATURES IN THE DATASET ARE LESS THAN 10, WE DONOT APPLY RELIEFF ALGORITHM
                            %TRAIN GRNN
                            Grnn{i}=newgrnn(Input',Output');
                            
                            %CHOOSE THE INPUT COLUMN FOR SIMULATION
                            Input_sim_temp=Normalized_dataset;
                            Input_sim_temp(:,col1)=[];
                            Input_sim=Input_sim_temp(row(i),:);
                        end
                        
                        
                        %IMPUTE THE MISSING VALUE USING SIM
                        imputed(i)=sim(Grnn{i},Input_sim');

                        k=k+1;
                    end
                end
                 
                 %CONSTRUCT THE IMPUTED DATASET BY PUTTING THE MISSING VALUES IN THE NORMALIZED DATASET
                 for p=1:n
                     Normalized_dataset(row(p),col(p))=imputed(p);
                 end
                 
                 
                 %CALCULATE THE MEAN OF IMPUTED VALUES
                 conditional_mean(q)=mean(imputed);
                 difference(q)=conditional_mean(q)-conditional_mean(q-1);
        
           end
    end
    
    %DENORMALIZE THE IMPUTED MATRIX
    for c=1:size(dataset,2)
        for r=1:size(dataset,1)
            minVal=min(dataset(:,c));
            maxVal=max(dataset(:,c));
            imputed_dataset(r,c)=minVal + (Normalized_dataset(r,c))*(maxVal-minVal);
        end
    end
    
    %FOR LARGE DATASET WE TRANSPOSE IT BACK TO ORIGINAL
    if flag=='Large data'
       imputed_dataset=imputed_dataset';
    end
    
    %CALCULATE NRMS VALUE
    all_val= orig_dataset(:,:).^2; %square each term
    s=sum(all_val(:));%sum of all squares
    original_data=sqrt(s);%square root of sum

    difference_nrms=orig_dataset-imputed_dataset;
    all_val1= difference_nrms(:,:).^2;
    s1=sum(all_val1(:));
    difference_data=sqrt(s1);

    NRMS=difference_data/original_data;
    display(NRMS)    
    
    %SAVE THE IMPUTED DATSET IN OUTPUT DIRECTORY
    [m1,m2,m3]=fileparts(list(counter).name);
    xlswrite([output_dir,m2,'_filled.xlsx'],imputed_dataset)
    
    
    m2_values(counter)={m2};       %MAKE A LIST OF FILENAMES
    NRMS_values(counter)={NRMS};   %MAKE A LIST OF NRMS VALIUE
    missing_values(counter)={n};   %MAKE A LIST OF NO. OF MISSING VALUES
    time_values(counter)={toc};    %MAKE A LIST OF COMPUTATIONAL TIME
    
    %SAVE THE RESULTS OF A INCOMPLETE DATASET IN A SINGLE EXCEL FILE
    header_temp={'Dataset Name','NRMS Value','no. of missing values','Imputation Time(sec)'};
    output_temp1={m2,NRMS,n,toc};
    output_temp2=[header_temp;output_temp1];
    xlswrite([output_dir,m2,'_output.xlsx'],output_temp2);
end

%SAVE RESULTS FOR ALL DATASETS IN A SINGLE FILE
dataoutput=[m2_values',NRMS_values',missing_values',time_values'];
header={'Dataset Name','NRMS Value','no. of missing values','Imputation Time(sec)'};
dataoutput2=[header;dataoutput];
xlswrite([output_dir,'output.xlsx'],dataoutput2)
display("Imputation complete")