population_size = 100;
Ngen = 1000;
fitness_data = zeros(1, Ngen);
world_grid = readmatrix("muir_world.txt");
avg_fitness_vals = zeros(1, Ngen);
states = [1 4 7 10 13 16 19 22 25 28];

%% Prompt the user to select options
prompt = "Choose selection technique\n(1) - Roulette Wheel\n(2) - Tournament\n(3) - Linear rank\n";
selection_technique = input(prompt);

prompt = "Choose crossover technique\n(1) - K-point\n(2) - Uniform\n";
crossover_technique = input(prompt);

prompt = "Choose mutation technique\n(1) - Uniform\n(2) - Parameter swap\n";
mutation_technique = input(prompt);

%% START - Generate random population of n chromosomes
population = zeros(population_size,30);
for i = 1:population_size
    for j = 1:3:30
        population(i, j) = randi(4, 1);
        population(i, j+1) = randi(10, 1) - 1;
        population(i, j+2) = randi(10, 1) - 1;
    end
end

%% END CONDITION - ends when we reach a maximum number of generations
for i = 1:Ngen
    %% FITNESS - Evaluate the fitness of each chromosome
    for j = 1:population_size
        population(j, 31) = simulate_ant(world_grid, population(j,1:30));
    end

    %% Save fitness of fittest ant in generation
    population = sortrows(population, 31);
    fitness_value = simulate_ant(world_grid, population(population_size, 1:30));
    fitness_data(1, i) = population(population_size, 31);

    %% END CONDITION - ends when the average fitness value has stayed the same for 10 generations
%     avg_fitness_vals(i) = mean(population(:,31));
%     if (i > 10) && (all(avg_fitness_vals(1, i-10:i) == avg_fitness_vals(1, i)))
%         break;
%     end

    %% REPLACEMENT
    %% Elitism, keep best 2
    population_new = zeros(population_size,30);
    population_new(1:2,:) = population(population_size-1:population_size,1:30);
    population_new_num = 2;

    %% Generational
%     population_new = zeros(population_size,30);
%     population_new_num = 0;
    
    %% NEW POPULATION - create a new population by repeating
    % Loops until we have a new population that is as big as population_size
    while (population_new_num < population_size)
        %% SELECTION - select 2 parent chromosomes based on their fitness
        if selection_technique == 1
            %% Roulette wheel selection
            weights = population(:, 31) / sum(population(:, 31));
            choice1 = Selection(weights);
            choice2 = Selection(weights);
            temp_chromosome_1 = population(choice1, 1:30);
            temp_chromosome_2 = population(choice2 ,1:30);
        elseif selection_technique == 2
            %% Tournament selection
            choice1 = TournamentSelection(population(:,31), population_size);
            choice2 = TournamentSelection(population(:,31), population_size);
            temp_chromosome_1 = population(choice1, 1:30);
            temp_chromosome_2 = population(choice2 ,1:30);
        else
            %% Linear rank selection
            for j = 1:population_size
               population(j,31) = i;
            end
            weights = population(:, 31) / sum(population(:, 31));
            choice1 = Selection(weights);
            choice2 = Selection(weights);
            temp_chromosome_1 = population(choice1, 1:30);
            temp_chromosome_2 = population(choice2 ,1:30);
        end

        %% CROSSOVER - with a crossover probability, cross over the parents to form new offspring
        if crossover_technique == 1
            %% K-point crossover, K = 1
            if (rand < 0.8)
               % pick a crossover point
               cross_over_point = randi(29,1,1);
               % perform crossover
               temp = temp_chromosome_1(cross_over_point:end);
               temp_chromosome_1(cross_over_point:end) = temp_chromosome_2(cross_over_point:end);
               temp_chromosome_2(cross_over_point:end) = temp;
            end
        else
            %% Uniform crossover
            if (rand < 0.8)
                random_numbers = rand(1, 30);
                for j = 1:30
                    if random_numbers(1, j) >= 0.5
                        temp = temp_chromosome_1(j);
                        temp_chromosome_1(j) = temp_chromosome_2(j);
                        temp_chromosome_2(j) = temp;
                    end
                end
            end
        end
        
        %% MUTATION - with a mutation probability, mutate new offspring at each position in chromosome
        if mutation_technique == 1
            %% Uniform mutation
            % Picks a random parameter and sets a new random value within the correct range
            if (rand < 0.2)
                location = randi(30, 1, 1);
                if ismember(location, states)
                    temp_chromosome_1(location) = randi(4,1,1);
                else
                    temp_chromosome_1(location) = randi(10,1,1) - 1;
                end
            end
            
            if (rand < 0.2)
                location = randi(30, 1, 1);
                if ismember(location, states)
                    temp_chromosome_2(location) = randi(4,1,1);
                else
                    temp_chromosome_2(location) = randi(10,1,1) - 1;
                end
            end
        else
            %% Parameter swap mutation
            % Picks 2 random locations and swaps the parameters
            if (rand < 0.2)
                location_1 = randi(30, 1, 1);
                location_2 = randi(30, 1, 1);
                if ismember(location_1, states)
                    while (~ismember(location_2, states))
                        location_2 = randi(30, 1, 1);
                    end
                else
                    while (ismember(location_2, states))
                        location_2 = randi(30, 1, 1);
                    end
                end

                temp = temp_chromosome_1(location_1);
                temp_chromosome_1(location_1) = temp_chromosome_1(location_2);
                temp_chromosome_1(location_2) = temp;
            end

            if (rand < 0.2)
                location_1 = randi(30, 1, 1);
                location_2 = randi(30, 1, 1);
                if ismember(location_1, states)
                    while (~ismember(location_2, states))
                        location_2 = randi(30, 1, 1);
                    end
                else
                    while (ismember(location_2, states))
                        location_2 = randi(30, 1, 1);
                    end
                end

                temp = temp_chromosome_2(location_1);
                temp_chromosome_2(location_1) = temp_chromosome_2(location_2);
                temp_chromosome_2(location_2) = temp;
            end
        end
        
        %% ACCEPTING - place new offspring in new population
        population_new_num = population_new_num + 1;
        population_new(population_new_num,:) = temp_chromosome_1;

        population_new_num = population_new_num + 1;
        population_new(population_new_num,:) = temp_chromosome_2;
    end

    population(:,1:30) = population_new;
end

%% Evaluate fitness of final generation
for i = 1:population_size
    population(i, 31) = simulate_ant(world_grid, population(i,1:30));
end

%% Generate a plot showing the fitness score of the most-fit ant in each generation
hf = figure(1); set(hf,'Color',[1 1 1]);
hp = plot(1:Ngen,100*fitness_data/89,'r');
set(hp,'LineWidth',2);
axis([0 Ngen 0 100]); grid on;
xlabel('Generation number');
ylabel('Ant fitness [%]');
title('Ant fitness as a function of generation');

population = sortrows(population, 31);
[best_fitness, trail] = simulate_ant(world_grid, population(population_size,1:30));

%% display the John Moir Trail (world)
world_grid = rot90(rot90(rot90(world_grid)));
xmax = size(world_grid,2);
ymax = size(world_grid,1);

hf = figure(2); set(hf,'Color',[1 1 1]);
for y=1:ymax
    for x=1:xmax
        if(world_grid(x,y) == 1)
            h1 = plot(x,y,'sk');
            hold on
        end
    end
end
grid on

%% display the fittest Individual trail
for k=1:size(trail,1)
    h2 = plot(trail(k,2),33-trail(k,1),'*m');
    hold on
end
axis([1 32 1 32])
title_str = sprintf('John Muri Trail - Hero Ant fitness %d%% in %d generation ',uint8(100*best_fitness/89), Ngen);
title(title_str)
lh = legend([h1 h2],'Food cell','Ant movement');
set(lh,'Location','SouthEast');

%% Helper functions
function choice = TournamentSelection(fitness_values, pop_size)
    chromosome1 = randi(pop_size, 1);
    chromosome2 = randi(pop_size, 1);

    if fitness_values(chromosome1) > fitness_values(chromosome2)
        choice = chromosome1;
    else
        choice = chromosome2;
    end
end

function choice = Selection(weights)
    accumulation = cumsum(weights);
    p = rand();
    chosen_index = -1;
    for index = 1 : length(accumulation)
        if (accumulation(index) > p)
            chosen_index = index;
            break;
        end
    end
    choice = chosen_index;
end