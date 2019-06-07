document.addEventListener("turbolinks:load", function() {

	let toggles = { one: document.querySelector('#toggle_one input') };
	let collapsables = { one: document.querySelector('#collapsable_one') };
	console.log(Object.keys(toggles))
	Object.keys(toggles).forEach(key => {
		toggles[key].addEventListener('change', (e) => {
			if (e.target.checked) {
				collapsables[key].className = "expanded"
			} else {
				collapsables[key].className = "collapsed"
			}
		});
	});

});
