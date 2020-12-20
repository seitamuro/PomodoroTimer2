var xhr = new XMLHttpRequest();
var time = 0;
var started = false;

var WORKTYPE = {
	WORK: 0,
	REST: 1
};

function starttimer(seconds, worktype) {
	var d = new Date();
	var now = d.getTime()/1000;
	var seconds = parseInt(seconds);

	if (isNaN(seconds)) {
		return ;
	}

	if (!started) {
		started = true;
		setTimeout(function() {
			submit_pomodoro(now, now+seconds, worktype)
		}, seconds*1000);

		time = seconds;
		display_timer();
	}
}

function zeroPadding(number, digit) {
	var i;
	var zeros = "";
	var number = String(number);
	for (i = 0;i < digit;i++) {
		zeros = zeros + "0";
	}
	return (zeros + number).slice(number.length);
}

function display_timer() {
	var usec = time;
	var minite = Math.floor(usec / 60);
	var second = usec % 60;
	document.getElementById("timer").innerHTML = minite + ":" + zeroPadding(second, 2);
	time = time - 1;

	if (time >= 0) {
		setTimeout("display_timer()", 1000);
	} else {
		started = false;
	}
}

function submit_pomodoro(starttime, endtime, worktype) {
	var formData = new FormData();

	formData.append("starttime", starttime);
	formData.append("endtime", endtime);
	formData.append("worktype", worktype);

	xhr.open("POST", "http://127.0.0.1:9998/submitpomodoro");
	xhr.send(formData);
}

function changeButtonText(origin, target, worktype) {
	var value = document.getElementById(origin).value;
	value = parseInt(value);
	document.getElementById(target).value = value + "分の作業開始";
	document.getElementById(target).onclick = null;
	document.getElementById(target).addEventListener("click", function() {
		starttimer(value*60, worktype)
	});
}
