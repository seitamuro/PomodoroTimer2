function checkValue(id1, id2)
{
	var v1 = document.getElementById(id1).value;
	var v2 = document.getElementById(id2).value;

	if (v1 == v2) {
		return true;
	} else {
		document.getElementById("message").innerHTML = "パスワードが一致していません。";
		return false;
	}
}
