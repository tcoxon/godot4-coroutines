extends Control

func _ready():
	var result = Co.async(run_all_races)
	print("==> ", result)
	if result is FunctionState:
		result = await result.completed
	print("==> ", result)

func run_all_races() -> Array:
	var winners = await Co.join([
		Co.async(run_race1),
		Co.async(run_race2)
	]).completed
	print("The winners of the races were: ", winners)
	return winners

func run_race1() -> String:
	var winner = await Co.select([
		Co.async(race_horse.bind("foo")),
		Co.async(race_horse.bind("bar")),
		Co.async(race_horse.bind("baz"))
	]).completed
	print("The winner of race1 is ", winner, "!")
	return winner

func run_race2() -> String:
	var winner = await Co.select([
		Co.async(race_horse.bind("alice")),
		Co.async(race_horse.bind("bob")),
		Co.async(race_horse.bind("eve"))
	]).completed
	print("The winner of race2 is ", winner, "!")
	return winner

func race_horse(horse_name: String) -> String:
	await get_tree().create_timer(randf() * 2).timeout
	print(horse_name, " finished")
	return horse_name
