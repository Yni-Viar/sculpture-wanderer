extends Node2D
## Used from Unity package https://github.com/runevision/LocomotionSystem
## To make tribute for Bientot l'ete game by Tale of Tales (I am a fan of them and their works)
## Copyright (c) 2008-2020, Rune Skovbo Johansen. Licensed according to the Mozilla Public License Version 2.0.
## Ported to Godot by Yni Viar.
class_name TrajectoryVisualizer

class TimePoint:
	var time: float
	var point: Vector3
	func _init(time: float, point: Vector3):
		self.time = time;
		self.point = point;

@export var color: Color = Color.WHITE
@export var length:float = 16384.0
@export var camera: Camera3D
var dotted:bool
var trajectory: Array[TimePoint] = []


func add_point(time: float, point: Vector3):
	trajectory.append(TimePoint.new(time, point))
	while (trajectory[0].time<time-length):
		trajectory.remove_at(0);
	
func _draw() -> void:
	if camera != null && trajectory.size() > 0:
		## Debug.Log("Point count: "+trajectory.Count);
		#DrawArea draw = new DrawArea3D(Vector3.zero,Vector3.one,Matrix4x4.identity);
		var curTime: float = trajectory[trajectory.size()-1].time;
		#GL.Begin(GL.LINES);
		for i in range(trajectory.size()-1):
			var col: Color = color;
			#col.a = (curTime-trajectory[i].time)/length;
			#col.a = 1-col.a*col.a;
			if trajectory[i].point.x < 0 && trajectory[i].point.y < 0 && \
			   trajectory[i+1].point.x < 0 && trajectory[i+1].point.y < 0 && \
			   camera.is_position_behind(trajectory[i].point) && camera.is_position_behind(trajectory[i+1].point):
				continue
			draw_line(camera.unproject_position(trajectory[i].point), camera.unproject_position(trajectory[i+1].point), col)
		#GL.End();

func _physics_process(delta: float) -> void:
	if visible:
		queue_redraw()
