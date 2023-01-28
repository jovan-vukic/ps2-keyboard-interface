<div id="top"></div>

<!-- PROJECT [othneildrew] SHIELDS -->

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <h2 align="center">PS2 Keyboard FPGA Interface - Jovan Vukić</h2>

  <p align="center">
    The project, made in the Verilog language, implements the necessary code for interfacing with a standard PS2 keyboard.
    <br />
    <a href="https://github.com/jovan-vukic/ps2-keyboard-interface"><strong>Explore the project »</strong></a>
    <br />
    <br />
    <a href="https://github.com/jovan-vukic/ps2-keyboard-interface/issues">Report Bug</a>
    ·
    <a href="https://github.com/jovan-vukic/ps2-keyboard-interface/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#usage">Usage</a></li>
        <li><a href="#important-note">Important note</a></li>
      </ul>
    </li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

The project, made in the Verilog language, implements the code for interfacing with a standard PS2 keyboard.

The code was tested by synthesizing it on a Cyclone III FPGA board. After the synthesis:
* when a key is pressed on the connected keyboard, the four seven-segment displays will show the last two bytes of the generated make code as long as the key is pressed,
* if the pressed key is released, the four seven-segment displays will show the last two bytes of the generated break code.

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

To set up the project, you will need to:

* install [Quartus II Web Edition version 13.0sp1](https://www.intel.com/content/www/us/en/software-kit/711791/intel-quartus-ii-web-edition-design-software-version-13-0sp1-for-windows.html),

* install QuestaSim version 10.4c,

* install Visual Studio Code,

* install [Icarus Verilog compiler](http://bleyer.org/icarus),

* get the [Verilog-HDL/SystemVerilog/Bluespec SystemVerilog](https://marketplace.visualstudio.com/items?itemName=mshr-h.VerilogHDL) VS Code extension,

* in the extension's settings set:

  * Linter to `iverilog`,

  * Iverilog Arguments to `-c ./tooling/config/list-icarus-verilog.lst`.

### Usage

Setup & execution:

1. Clone the repo:

   ```sh
   git clone https://github.com/jovan-vukic/ps2-keyboard-interface
   ```
2. Open the terminal in VS Code and type the following:

   ```sh
   C:/"Program Files"/altera/13.0sp1/quartus/bin/cygwin/bin/bash
   ```
3. Change the current folder to the `tooling` folder:

   ```sh
   cd tooling
   ```
4. Type the following to start the `testbench_verification_uvm.sv` test:

   ```sh
    ./xpack/bin/make simul_run
   ```
5. Type the following to synthesize the `ps2.v` module on the connected Cyclone III FPGA board:

   ```sh
    ./xpack/bin/make synth_pgm
   ```
6. To get the additional make tool options type into the terminal in VS Code:

   ```sh
    ./xpack/bin/make help
   ```

### Important Note

The PS2 keyboard specifications include three Scan Code Sets.

* Scan Code Set 1 is the old XT mode rarely available on keyboards.
* Scan Code Set 2 is the default Scan Code Set guaranteed to work.
* Scan Code Set 3 is even rarer to find.

It should be noted that this implementation only supports PS2 Scan Code Set 2.

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.md` for more information.

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

Jovan - [@jovan-vukic](https://github.com/jovan-vukic)

Project Link: [https://github.com/jovan-vukic/ps2-keyboard-interface](https://github.com/jovan-vukic/ps2-keyboard-interface)

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

Used resources:

* [The full specification of the project in the Serbian language](./docs/doc%20(v1.0).pdf)

<p align="right">(<a href="#top">back to top</a>)</p>
