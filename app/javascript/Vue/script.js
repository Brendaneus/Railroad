// import TurbolinksAdapter from 'vue-turbolinks'
import Vue from 'vue/dist/vue.esm'

// Vue.use(TurbolinksAdapter)


/* eslint-disable no-new */
document.addEventListener('turbolinks:load', loadVue, { once: true })
document.addEventListener('turbolinks:render', loadVue)

function loadVue () {
	console.log("test")

	if (document.querySelector('#test') == null) return

	Turbolinks.clearCache()

	new Vue({

})
}