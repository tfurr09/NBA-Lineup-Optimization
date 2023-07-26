# Read in the data

using CSV, DataFrames
data = DataFrame(CSV.File("C:\\Users\\tfurr\\OneDrive\\Documents\\optprojectdata.csv"))
size(data)

# Only keep necessary columns. Also makes sure we drop duplicate players that show up

data = data[:,1:34]
data = unique(data[completecases(data), :])
data[1:5,:]

# Some players names are spelled wrong or Julia has some difficulty with non-English characters

data.Player = replace.(data.Player, "Kawhi Leord" => "Kawhi Leonard")
data.Player = replace.(data.Player, "Willy Herng\xf3mez" => "Willy Hernangomez")

# The main data frame we will deal with keeps these variables. MinM is minimum number of minuts that need to be played to qualify

df = data[:, [:PlayerID, :Player, :Pos, :MP, :MinM, :PER, :X2022_23, :C, :SG, :SF, :PG, :PF]]
df[1:5,:]

# Functions that will help us create our tables of players that are included in our model

function find_players_binary(vector)
    playerlist = []
    for i in 1:length(vector)
        if vector[i] == 1
            push!(playerlist, i)
        end
    end
    return playerlist
end

function find_players_string(include_players)
    playerlist = []
    for player in include_players
        player_index = findfirst(x -> occursin(player, x), df.Player)
        push!(playerlist, player_index)
    end
    return playerlist
end

# see if a player is located in the df
my_player_index = findfirst(x -> occursin("Russell Westbrook", x), df.Player)

# print the index
println("This player is located at index $my_player_index.")

search_player = filter(row -> contains(row.Player, "Russell Westbrook"), df)

# include whatever players you want to this list
include_players = []

# list of positions
positions = ["C", "SG", "SF", "PG", "PF"]

# establish budget
budget = 134000000

using JuMP, GLPK;

model = Model(GLPK.Optimizer)

# If you only want to include a subset of players, change n
n = nrow(df)

# c is the column vector of PER
c = df[1:n, 6]

# a is the column vector of salaries
a = df[1:n, 7]

# matrix of positions
mat = df[1:n ,8:12]

# Minimum minutes that need to be played to qualify to be in the model
min_m = df[!,5]

# Minutes played for each player
mp = df[!,4]

@variable(model, x[i=1:n], Bin)

# add requirements for players to include
for player in include_players
    player_index = findfirst(x -> occursin(player, x), df.Player)
    @constraint(model, sum(x[player_index]) == 1)
end

# limiting to no more than 5 per position
for p in positions
    pos = df[!, p]
    @constraint(model, sum(pos[i]*x[i] for i = 1:n) <= 5)
end

# ensuring that players included have played enough games/minutes
for i = 1:n
    @constraint(model, mp[i] >= min_m[i]*x[i])
end


# budget
@constraint(model, sum(a[i]*x[i] for i = 1:n) <= budget)

# 14 <= number of players <= 15
@constraint(model, sum(x[i] for i=1:n) <= 15)
@constraint(model, sum(x[i] for i=1:n) >= 14)

# Makes sure we have at least 2 players from each position
for j = 1:5
    @constraint(model, sum(x[i]*mat[i, j] for i=1:n) >= 2)
end

@objective(model, Max, sum(c[j]*x[j] for j=1:n))

JuMP.optimize!(model)

println("Objective value: ", JuMP.objective_value(model))
println("Average PER: ", (JuMP.objective_value(model))/15)

# This gives us our team

vector = JuMP.value.(x)
guess = df[find_players_binary(vector), [2,3,6,7]]

total_salary = sum(guess[:, 4]) # The total salary is under the salary cap

include_players = ["Nicolas Batum", 
                   "Brandon Boston Jr.", 
                   "Amir Coffey", 
                   "Robert Covington", 
                   "Paul George",
                   "Eric Gordon",
                   "Bones Hyland",
                   "Kawhi Leonard",
                   "Terance Mann",
                   "Marcus Morris",
                   "Mason Plumlee",
                   "Norman Powell",
                   "Jason Preston",
                   "Russell Westbrook"]

clippers_roster = df[find_players_string(include_players), [2,3,6,7]]

sum(clippers_roster[:, 4]) # Check the current salary amount

budget = 250000000

clippers = Model(GLPK.Optimizer)

# Below variables are the same as above 
n = nrow(df)
c = df[1:n, 6]
a = df[1:n, 7]
mat = df[1:n ,8:12]

min_m = df[!,5]
mp = df[!,4]

@variable(clippers, x[i=1:n], Bin)

# add requirements for players to include
for player in include_players
    player_index = findfirst(x -> occursin(player, x), df.Player)
    @constraint(clippers, sum(x[player_index]) == 1)
end

# budget
@constraint(clippers, sum(a[i]*x[i] for i = 1:n) <= budget)

# 14 <= number of players <= 15
@constraint(clippers, sum(x[i] for i=1:n) <= 15)
@constraint(clippers, sum(x[i] for i=1:n) >= 14)


# adjusting number of players per position
for p in positions
    pos = df[!, p]
    @constraint(clippers, sum(pos[i]*x[i] for i = 1:n) <= 6)
    @constraint(clippers, sum(pos[i]*x[i] for i = 1:n) >= 0)
end

for i = 1:n
    @constraint(clippers, mp[i] >= min_m[i]*x[i])
end

@objective(clippers, Max, sum(c[j]*x[j] for j=1:n))

JuMP.optimize!(clippers)

println("Objective value: ", JuMP.objective_value(clippers))

println("Average PER:", (JuMP.objective_value(clippers))/15)

# Here is our team. Note that Ja Morant is the player that was added

vector = JuMP.value.(x)
guess = df[find_players_binary(vector), [2,3,6,7]]

sum(guess[:,4]) #Budget works

include_players = ["Devin Booker", 
                   "Kevin Durant", 
                   "Chris Paul"]

suns_roster = df[find_players_string(include_players), [2,3,6,7]]

budget = 150000000

suns = Model(GLPK.Optimizer)
n = nrow(df)
c = df[1:n, 6]
a = df[1:n, 7]
mat = df[1:n ,8:12]

min_m = df[!,5]
mp = df[!,4]

@variable(suns, x[i=1:n], Bin)

# add requirements for players to include
for player in include_players
    player_index = findfirst(x -> occursin(player, x), df.Player)
    @constraint(suns, sum(x[player_index]) == 1)
end

# budget
@constraint(suns, sum(a[i]*x[i] for i = 1:n) <= budget)

# 14 <= number of players <= 15
@constraint(suns, sum(x[i] for i=1:n) <= 15)
@constraint(suns, sum(x[i] for i=1:n) >= 14)


# limiting to no more than 5 per position
for p in positions
    pos = df[!, p]
    @constraint(suns, sum(pos[i]*x[i] for i = 1:n) <= 5)
    @constraint(suns, sum(pos[i]*x[i] for i = 1:n) >= 2)
end

for i = 1:n
    @constraint(suns, mp[i] >= min_m[i]*x[i])
end

@objective(suns, Max, sum(c[j]*x[j] for j=1:n))

JuMP.optimize!(suns)

println("Objective value: ", JuMP.objective_value(suns))

println("Average PER:", (JuMP.objective_value(suns))/15)

# Here is our team

vector = JuMP.value.(x)
guess = df[find_players_binary(vector), [2,3,6,7]]

sum(guess[:,4]) # Salary is good

include_players = ["Stephen Curry"]

not_include_players = ["Klay Thompson"]

budget = 150000000

warriors = Model(GLPK.Optimizer)
n = nrow(df)
c = df[1:n, 6]
a = df[1:n, 7]
mat = df[1:n ,8:12]
CENTER = df[1:n,8]
POWER_F = df[1:n,12]

min_m = df[!,5]
mp = df[!,4]

@variable(warriors, x[i=1:n], Bin)

# add requirements for players to include
for player in include_players
    player_index = findfirst(x -> occursin(player, x), df.Player)
    @constraint(warriors, sum(x[player_index]) == 1)
end

# add requirements for players to NOT include
for player in not_include_players
    player_index = findfirst(x -> occursin(player, x), df.Player)
    @constraint(warriors, sum(x[player_index]) == 0)
end

# budget
@constraint(warriors, sum(a[i]*x[i] for i = 1:n) <= budget)

# 14 <= number of players <= 15
@constraint(warriors, sum(x[i] for i=1:n) <= 15)
@constraint(warriors, sum(x[i] for i=1:n) >= 14)


# sum of CENTER column is 0 to make sure we include 0 centers
@constraint(warriors, sum(CENTER[i]*x[i] for i=1:n) == 0)

# sum of POWER_F column is 0 to make sure we include 0 power forwards
@constraint(warriors, sum(POWER_F[i]*x[i] for i=1:n) == 0)

for i = 1:n
    @constraint(warriors, mp[i] >= min_m[i]*x[i])
end

@objective(warriors, Max, sum(c[j]*x[j] for j=1:n))

JuMP.optimize!(warriors)

println("Objective value: ", JuMP.objective_value(warriors))

println("Average PER:", (JuMP.objective_value(warriors))/15)

# This is our team. Notice it is all PG, SG and SF. Mainly 3-point shooters

vector = JuMP.value.(x)
guess = df[find_players_binary(vector), [2,3,6,7]]

sum(guess[:,4]) # Total salary for this team. It stays under the amount we said
