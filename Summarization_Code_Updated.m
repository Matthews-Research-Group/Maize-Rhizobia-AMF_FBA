% Summary analysis

% Need to get 95% CI of predictions for each N/P level for
% 1. RGR benefit
% 2. Carbon investment 

% Logic
% Iterate through each results file, extracting 
% RGR, base
% RGR, noBacteroidwithAMF - gives RGR benefit
% Glucose
% Palmitate
% CO2 - Gives carbon investment

% Calculate the derivative values and add these to a 11*11*100 array. 
% Once all are done, calculate 95% CI for each cell for the two
% predictables

RGR_benefit_all = struct([])
allocation_all = struct([])

for i=1:1800
    try
        filename = sprintf('Nvary_results_corrected_%d.mat',i)
        data = load(filename,'x')
        data = struct2cell(data(1))
        data = data{1}
        baseline_RGR = cell2mat(data{3})
        baseline_RGR = baseline_RGR(2:end,2:end)
        withAMF_RGR = cell2mat(data{9})

        difference = withAMF_RGR - baseline_RGR
        RGR_improvement = (difference ./ baseline_RGR).*100

        glucose = cell2mat(data{18})*6    
        palmitate = cell2mat(data{21})*16
        CO2 = cell2mat(data{24})
        total = glucose + palmitate
        allocation = (total ./ CO2)*100

        RGR_benefit_all{i} = RGR_improvement
        allocation_all{i} = allocation
    catch
    end
end

total_RGR = zeros(10,10)
total_allocation = zeros(10,10)

for i=1:100
    try
        total_RGR = total_RGR + RGR_benefit_all{i}
        total_allocation = total_allocation + allocation_all{i}
    catch
    end
end

average_RGR = total_RGR ./ 100
average_allocation = total_allocation ./ 100

RGR_sds_upper = zeros(10,10)
RGR_sds_lower = zeros(10,10)

% RGR benefit
for i=1:10
    for n=1:10
        initial_intermediate_SDs = zeros(100)
        intermediate_SDs = zeros(100)
        for x=1:100
            try
                RGR_benefits = RGR_benefit_all{x}
                value = RGR_benefits(i,n)
                initial_intermediate_SDs(x) = value
            catch
            end
        end
        intermediate_SDs = initial_intermediate_SDs(1:end,1)
        intermediate_SDs = intermediate_SDs(intermediate_SDs~=0)
        A = sort(intermediate_SDs)
        Upper = prctile(A,97.5)
        Lower = prctile(A,2.5)
        
        RGR_sds_upper(i,n) = Upper
        RGR_sds_lower(i,n) = Lower
    end
end
% Allocation

Allocation_sds = zeros(10,10)
Allocation_sds_upper = zeros(10,10)
Allocation_sds_lower = zeros(10,10)

for i=1:10
    for n=1:10
        initial_intermediate_SDs = zeros(100)
        intermediate_SDs = zeros(100)
        for x=1:100
            try
                allocation = allocation_all{x}
                value = allocation(i,n)
                initial_intermediate_SDs(x) = value
            catch
            end
        end
        intermediate_SDs = initial_intermediate_SDs(1:end,1)
        intermediate_SDs = intermediate_SDs(intermediate_SDs~=0)
        A = sort(intermediate_SDs)
        Upper = prctile(A,97.5)
        Lower = prctile(A,2.5)
        
        Allocation_sds_upper(i,n) = Upper
        Allocation_sds_lower(i,n) = Lower
    end
end
            
%%
