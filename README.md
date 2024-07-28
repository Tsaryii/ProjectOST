# TycoonKitX 🚀

TycoonKitX is a comprehensive kit built in the Verse programming language that emphasizes proper Object-Oriented programming interfaces. It allows users to easily create their own purchasable items, such as computers or any other custom devices, by simply adding one file.

![Build Status](https://img.shields.io/github/workflow/status/Tsaryii/TycoonKitX/CI)
![License](https://img.shields.io/github/license/Tsaryii/TycoonKitX)

## Table of Contents

- [Installation](#installation)
- [Additions](#additions)
- [Features](#features)
- [Screenshots](#screenshots)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Installation

1. Optional -> Clone the repo
   ```sh
   git clone https://github.com/Tsaryii/TycoonKitX.git

OR

1. Create new UEFN / Verse Project
    ![Screenshot 1](./Images/CreateUEFN.png)
2. Copy paste repo into UEFN / Verse explorer
    ![Screenshot 1](./Images/AddedFiles.png)

## Additions
Creating a new purchaseable is super easy simply do the following...

1. Create a new file under the purchaseables folder and copy / paste the basic_prop template.
    ![Screenshot 1](./Images/ExamplePropBuyable.png)

2. Add the new purchaseable to the BaseManager.verse
    ![Screenshot 2](./Images/BasicPropExample.png)

3. Create a newpurchasetype enum value
    ![Screenshot 3](./Images/NewPurchaseType.png)

4. Ensure the item gets initialized
    ![Screenshot 4](./Images/Initialize.png)

5. If the item needs to handle a rebirth add it to the rebirthable config
    ![Screenshot 5](./Images/Onrebirth.png)

## Features

Emphasizes proper Object-Oriented programming interfaces
Easily create custom purchasable items
Simple integration by adding a single file
Extensible and modular design

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

1. Fork the Project
2. Create your Feature Branch (git checkout -b feature/AmazingFeature)
3. Commit your Changes (git commit -m 'Add some AmazingFeature')
4. Push to the Branch (git push origin feature/AmazingFeature)
5. Open a Pull Request


## License
Distributed under the GPL 3.0 License. See LICENSE for more information.

## Acknowledgments
- Fortnite Docs
- Open Source Community
- FNC Discord