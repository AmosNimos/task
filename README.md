<body>

<h1 align="center">TaskCLI 📋</h1>

<p align="center">
  <i>Effortlessly manage your tasks right from the command line!</i><br>
  <b>Created by Amosnimos</b>
</p>

<h2>Overview</h2>
<img src="https://cheqmark.io/blog/wp-content/uploads/2023/03/what-is-checklist.jpg" alt="banner" style="height:340px"></img>
<p>
  TaskCLI is a simple, lightweight Python-based tool to manage tasks in your terminal. Add, remove, view, and edit tasks with ease, 
  keeping everything organized and available directly from the command line.
</p>

<h2>Features</h2>
<ul>
  <li><b>Add New Tasks</b>: Quickly add tasks with descriptions.</li>
  <li><b>View All Tasks</b>: Displays all tasks, organized by date.</li>
  <li><b>Edit Task Descriptions</b>: Easily update the details of any task.</li>
  <li><b>Remove Tasks</b>: Remove tasks by index or delete all tasks in one go.</li>
</ul>

<h2>Installation</h2>
<p>
  Clone the repository and navigate into the directory:
</p>

<pre><code>git clone https://github.com/Amosnimos/TaskCLI.git
cd TaskCLI
</code></pre>

<p>Make sure you have Python 3 installed, then you're ready to go!</p>

<h2>Usage</h2>
<p>Here’s how you can use TaskCLI:</p>

<pre><code>python task.py add "Your new task"       # Add a new task
python task.py remove &lt;index&gt;            # Remove a task by index
python task.py remove all                # Remove all tasks
python task.py edit &lt;index&gt;              # Edit a task description
python task.py                           # View all tasks
python task.py -h or --help              # Show help
</code></pre>

<h3>Examples</h3>
<ul>
  <li><b>Adding a Task:</b>
    <pre><code>python task.py add "Finish report"</code></pre>
  </li>
  <li><b>Viewing Tasks:</b>
    <pre><code>python task.py</code></pre>
  </li>
  <li><b>Editing a Task:</b>
    <pre><code>python task.py edit 2</code></pre>
    <i>Displays the current description and prompts for an update.</i>
  </li>
  <li><b>Removing a Task:</b>
    <pre><code>python task.py remove 1</code></pre>
    <i>Removes the task at index 1. Use <code>remove all</code> to clear the list.</i>
  </li>
</ul>

<h2>Why TaskCLI?</h2>
<p>
  TaskCLI is a minimalist’s dream for terminal task management. It’s designed for those who want a fast, distraction-free way 
  to handle their to-do lists right in the terminal.
</p>

<h2>Future Improvements</h2>
<ul>
  <li><b>Priority-based colors</b>: Easily spot important tasks.</li>
  <li><b>Date-based filters</b>: Focus on tasks due soon.</li>
  <li><b>Export Options</b>: Export tasks to plain text or CSV.</li>
</ul>

<h2>License</h2>
<p>
  TaskCLI is licensed under the <a href="https://www.gnu.org/licenses/agpl-3.0.html" target="_blank">GNU Affero General Public License v3.0</a>.
  You are free to use, modify, and share this tool as per the terms of this license.
</p>

<h2>Requirements</h2>
<p>TaskCLI requires Python 3.x and works on any system with Python installed.</p>

<h2>Contributing</h2>
<p>Pull requests and suggestions are welcome! Feel free to improve TaskCLI, add features, or report issues on GitHub.</p>

<p align="center">Happy tasking! 🎉</p>

</body>
