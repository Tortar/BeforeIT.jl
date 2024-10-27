
# # Comparing the performance of the Julia and MATLAB implementations

# We can compare the performance of the Julia and MATLAB implementations
# by running the same model for the same number of epochs and measuring
# the time taken.

using BeforeIT, Plots, Statistics

parameters = BeforeIT.AUSTRIA2010Q1.parameters
initial_conditions = BeforeIT.AUSTRIA2010Q1.initial_conditions
T = 12*2 

function run(; multi_threading = false)
    model = BeforeIT.init_model(parameters, initial_conditions, T)
    data = BeforeIT.init_data(model);
    
    for _ in 1:T
        BeforeIT.one_epoch!(model; multi_threading = multi_threading)
        BeforeIT.update_data!(data, model)
    end
    return model, data
end

# we run the code to compile it first
@time run();
@time run(;multi_threading = true);

# time taken by the MATLAB code, computed independently on an Apple M1 chip
matlab_times = [3.1919, 3.2454, 3.1501, 3.1074, 3.1551]
matlab_time = mean(matlab_times)
matlab_time_std = std(matlab_times)

# time taken by the Julia code, computed as the average of 5 runs
n_runs = 5

julia_times_1_thread = zeros(n_runs)   
for i in 1:n_runs
    julia_times_1_thread[i] = @elapsed run();
end
julia_time_1_thread = mean(julia_times_1_thread)
julia_time_1_thread_std = std(julia_times_1_thread)

julia_times_multi_thread = zeros(n_runs)
for i in 1:5
    julia_times_multi_thread[i] =  @elapsed run(multi_threading = true);
end
julia_time_multi_thread = mean(julia_times_multi_thread)
julia_time_multi_thread_std = std(julia_times_multi_thread)

# get the number of threads used
n_threads = Threads.nthreads()

theme(:default, bg = :white)

# bar chart of the time taken vs the time taken by the MATLAB code, also plot the stds as error bars
# make a white background with no grid
bar(["MATLAB", "Julia, 1 thread", "Julia, $n_threads threads"], [matlab_time, julia_time_1_thread, julia_time_multi_thread], 
yerr = [matlab_time_std, julia_time_1_thread_std, julia_time_multi_thread_std],
legend = false, dpi=300, size=(400, 300), grid = false, ylabel = "Time for one simulation (s)")

# the Julia implementation is faster than the MATLAB implementation, and the multi-threaded version is
# faster than the single-threaded version.

# increase

# save the image
savefig("benchmark_w_matlab.png")
