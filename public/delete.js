var xhr = new XMLHttpRequest();

function del_pomodoro(id) {
	var formData = new FormData();

	formData.append("deleteid", id);
	xhr.open("DELETE", "http://127.0.0.1:9998/delete/pomodoro");
	xhr.send(formData);

	document.getElementById(id).style.display = "none";
}
