### A Pluto.jl notebook ###
# v0.19.3

using Markdown
using InteractiveUtils

# ╔═╡ ed0f13cc-4f7d-476b-a434-d14313d88eea
using Markdown: withtag

# ╔═╡ 6043d6c5-54e4-40c1-a8a5-aec3ad7e1aa0
md"# asdfsf"

# ╔═╡ f11f9ead-bbe9-4fa5-b99c-408cc4a69a7e
md"""

## Hello!!

# level 1

## level 2

### level 3

### level 3 again



asdf

# level 1 again

#### level 4

##### level 5

## back to 2
"""

# ╔═╡ d6940210-4f9b-47b5-af74-e53700a42417
const toc_js = toc -> """
const getParentCell = el => el.closest("pluto-cell")

const getHeaders = () => {
	const depth = Math.max(1, Math.min(6, $(toc.depth))) // should be in range 1:6
	const range = Array.from({length: depth}, (x, i) => i+1) // [1, ..., depth]
	
	const selector = range.map(i => `pluto-notebook pluto-cell h\${i}`).join(",")
	return Array.from(document.querySelectorAll(selector))
}

const indent = $(repr(toc.indent))
const aside = $(repr(toc.aside))

const clickHandler = (event) => {
	const path = (event.path || event.composedPath())
	const toc = path.find(elem => elem?.classList?.contains?.("toc-toggle"))
	if (toc) {
		event.stopImmediatePropagation()
		toc.closest(".plutoui-toc").classList.toggle("hide")
	}
}

document.addEventListener("click", clickHandler)


const render = (el) => html`\${el.map(h => {
	const parent_cell = getParentCell(h)

	const a = html`<a 
		class="\${h.nodeName}" 
		href="#\${parent_cell.id}"
	>\${h.innerText}</a>`
	/* a.onmouseover=()=>{
		parent_cell.firstElementChild.classList.add(
			'highlight-pluto-cell-shoulder'
		)
	}
	a.onmouseout=() => {
		parent_cell.firstElementChild.classList.remove(
			'highlight-pluto-cell-shoulder'
		)
	} */
	a.onclick=(e) => {
		e.preventDefault();
		h.scrollIntoView({
			behavior: 'smooth', 
			block: 'start'
		})
	}

	return html`<div class="toc-row">\${a}</div>`
})}`

const tocNode = html`<nav class="plutoui-toc">
	<header>
     <span class="toc-toggle open-toc">📖</span>
     <span class="toc-toggle closed-toc">📕</span>
	$(toc.title)</header>
	<section></section>
</nav>`

tocNode.classList.toggle("aside", aside)
tocNode.classList.toggle("indent", indent)

const updateCallback = () => {
	tocNode.querySelector("section").replaceWith(
		html`<section>\${render(getHeaders())}</section>`
	)
}
updateCallback()
setTimeout(updateCallback, 100)
setTimeout(updateCallback, 1000)
setTimeout(updateCallback, 5000)

const notebook = document.querySelector("pluto-notebook")


// We have a mutationobserver for each cell:
const observers = {
	current: [],
}

const createCellObservers = () => {
	observers.current.forEach((o) => o.disconnect())
	observers.current = Array.from(notebook.querySelectorAll("pluto-cell")).map(el => {
		const o = new MutationObserver(updateCallback)
		o.observe(el, {attributeFilter: ["class"]})
		return o
	})
}
createCellObservers()

// And one for the notebook's child list, which updates our cell observers:
const notebookObserver = new MutationObserver(() => {
	updateCallback()
	createCellObservers()
})
notebookObserver.observe(notebook, {childList: true})

// And finally, an observer for the document.body classList, to make sure that the toc also works when if is loaded during notebook initialization
const bodyClassObserver = new MutationObserver(updateCallback)
bodyClassObserver.observe(document.body, {attributeFilter: ["class"]})

// Hide/show the ToC when the screen gets small
let m = matchMedia("(max-width: 1000px)")
let match_listener = () => 
	tocNode.classList.toggle("hide", m.matches)
match_listener()
m.addListener(match_listener)

invalidation.then(() => {
	notebookObserver.disconnect()
	bodyClassObserver.disconnect()
	observers.current.forEach((o) => o.disconnect())
	document.removeEventListener("click", clickHandler)
	m.removeListener(match_listener)
})

return tocNode
"""

# ╔═╡ 731a4662-c329-42a2-ae71-7954140bb290
const toc_css = """
@media not print {

.plutoui-toc {
	--main-bg-color: unset;
	--pluto-output-color: hsl(0, 0%, 36%);
	--pluto-output-h-color: hsl(0, 0%, 21%);
}

@media (prefers-color-scheme: dark) {
	.plutoui-toc {
		--main-bg-color: hsl(0deg 0% 21%);
		--pluto-output-color: hsl(0, 0%, 90%);
		--pluto-output-h-color: hsl(0, 0%, 97%);
	}
}

.plutoui-toc.aside {
	color: var(--pluto-output-color);
	position:fixed;
	right: 1rem;
	top: 5rem;
	width: min(80vw, 300px);
	padding: 10px;
	border: 3px solid rgba(0, 0, 0, 0.15);
	border-radius: 10px;
	box-shadow: 0 0 11px 0px #00000010;
	/* That is, viewport minus top minus Live Docs */
	max-height: calc(100vh - 5rem - 56px);
	overflow: auto;
	z-index: 40;
	background-color: var(--main-bg-color);
	transition: transform 300ms cubic-bezier(0.18, 0.89, 0.45, 1.12);
}

.plutoui-toc.aside.hide {
	transform: translateX(calc(100% - 28px));
}
.plutoui-toc.aside.hide section {
	display: none;
}
.plutoui-toc.aside.hide header {
	margin-bottom: 0em;
	padding-bottom: 0em;
	border-bottom: none;
}
}  /* End of Media print query */
.plutoui-toc.aside.hide .open-toc,
.plutoui-toc.aside:not(.hide) .closed-toc,
.plutoui-toc:not(.aside) .closed-toc {
	display: none;
}

@media (prefers-reduced-motion) {
  .plutoui-toc.aside {
    transition-duration: 0s;
  }
}

.toc-toggle {
	cursor: pointer;
	padding: 1em;
	margin: -1em;
    margin-right: -0.7em;
}

.plutoui-toc header {
	display: block;
	font-size: 1.5em;
	margin-top: -0.1em;
	margin-bottom: 0.4em;
	padding-bottom: 0.4em;
	margin-left: 0;
	margin-right: 0;
	font-weight: bold;
	border-bottom: 2px solid rgba(0, 0, 0, 0.15);
}

.plutoui-toc section .toc-row {
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	padding-bottom: 2px;
}

.highlight-pluto-cell-shoulder {
	background: rgba(0, 0, 0, 0.05);
	background-clip: padding-box;
}

.plutoui-toc section a {
	text-decoration: none;
	font-weight: normal;
	color: var(--pluto-output-color);
}
.plutoui-toc section a:hover {
	color: var(--pluto-output-h-color);
}

.plutoui-toc.indent section a.H1 {
	font-weight: 700;
	line-height: 1em;
}

.plutoui-toc.indent section a.H1 {
	padding-left: 0px;
}
.plutoui-toc.indent section a.H2 {
	padding-left: 10px;
}
.plutoui-toc.indent section a.H3 {
	padding-left: 20px;
}
.plutoui-toc.indent section a.H4 {
	padding-left: 30px;
}
.plutoui-toc.indent section a.H5 {
	padding-left: 40px;
}
.plutoui-toc.indent section a.H6 {
	padding-left: 50px;
}
"""

# ╔═╡ 434cc67b-a1e8-4804-b7ba-f47d0f879046
begin
	"""Generate Table of Contents using Markdown cells. Headers h1-h6 are used. 

	# Keyword arguments:
	`title` header to this element, defaults to "Table of Contents"

	`indent` flag indicating whether to vertically align elements by hierarchy

	`depth` value to limit the header elements, should be in range 1 to 6 (default = 3)

	`aside` fix the element to right of page, defaults to true

	# Examples:

	```julia
	TableOfContents()

	TableOfContents(title="Experiments 🔬")

	TableOfContents(title="📚 Table of Contents", indent=true, depth=4, aside=true)
	```
	"""
	Base.@kwdef struct TableOfContents
		title::AbstractString="Table of Contents"
		indent::Bool=true
		depth::Integer=3
		aside::Bool=true
	end
	function Base.show(io::IO, ::MIME"text/html", toc::TableOfContents)
		withtag(io, :script) do
			print(io, toc_js(toc))
		end
		withtag(io, :style) do
			print(io, toc_css)
		end
	end
end

# ╔═╡ 98cd39ae-a93c-40fe-a5d1-0883e1542e22
export TableOfContents

# ╔═╡ fdf8750b-653e-4f23-8f8f-9e2ef4e24e75
TableOfContents()

# ╔═╡ 7c32fd56-6cc5-420b-945b-53446833a125
TableOfContents(; aside = false)

# ╔═╡ 06ac2f13-e1f7-477a-9b3c-4d8545b777d9


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Markdown = "d6f4376e-aef5-505a-96c1-9c027394607a"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
"""

# ╔═╡ Cell order:
# ╠═98cd39ae-a93c-40fe-a5d1-0883e1542e22
# ╠═ed0f13cc-4f7d-476b-a434-d14313d88eea
# ╠═fdf8750b-653e-4f23-8f8f-9e2ef4e24e75
# ╠═7c32fd56-6cc5-420b-945b-53446833a125
# ╟─6043d6c5-54e4-40c1-a8a5-aec3ad7e1aa0
# ╟─f11f9ead-bbe9-4fa5-b99c-408cc4a69a7e
# ╠═434cc67b-a1e8-4804-b7ba-f47d0f879046
# ╠═d6940210-4f9b-47b5-af74-e53700a42417
# ╠═731a4662-c329-42a2-ae71-7954140bb290
# ╠═06ac2f13-e1f7-477a-9b3c-4d8545b777d9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
