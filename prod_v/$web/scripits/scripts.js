<script>
let isLeftMenuVisible = false; 
let isRightContainerVisible = false;
let isRightContainer1Visible = false;

const toggleVisibility = (element, isVisible) => {
    element.style.display = isVisible ? 'block' : 'none';
};

const handleMenuClick = (event, container, isVisibleFlag) => {
    event.preventDefault();
    toggleVisibility(container, !isVisibleFlag);
    isVisibleFlag = !isVisibleFlag;
    event.target.classList.toggle('selected', isVisibleFlag);
    history.pushState({}, '', window.location.pathname + (isVisibleFlag ? `?selected=${event.target.id}` : ''));
    return isVisibleFlag;
};

window.addEventListener('load', () => {
    const urlParams = new URLSearchParams(window.location.search);
    const selected = urlParams.get('selected');

    if (selected) {
        const selectedItem = document.getElementById(selected);
        if (selectedItem) {
            selectedItem.classList.add('selected');
        }
    }
});

document.getElementById('ghaf-24.09.0').addEventListener('click', event => {
    event.preventDefault();
    const leftMenu = document.getElementById('left-menu');
    const rightContainer = document.querySelector('.right-container');
    const rightContainer1 = document.querySelector('.right-container-1');

    isLeftMenuVisible = !isLeftMenuVisible;
    toggleVisibility(leftMenu, isLeftMenuVisible);
    toggleVisibility(rightContainer, false);
    toggleVisibility(rightContainer1, false);
    isRightContainerVisible = false;
    isRightContainer1Visible = false;
   document.getElementById('ghaf-24.09').classList.remove('selected');
    document.getElementById('ghaf-24.09.1').classList.remove('selected');
});

document.getElementById('ghaf-24.09').addEventListener('click', event => {
    isRightContainerVisible = handleMenuClick(event, document.querySelector('.right-container'), isRightContainerVisible);
    toggleVisibility(document.querySelector('.right-container-1'), false);
    isRightContainer1Visible = false;
    document.getElementById('ghaf-24.09.1').classList.remove('selected');
});

document.getElementById('ghaf-24.09.1').addEventListener('click', event => {
    isRightContainer1Visible = handleMenuClick(event, document.querySelector('.right-container-1'), isRightContainer1Visible);
    toggleVisibility(document.querySelector('.right-container'), false);
    isRightContainerVisible = false;
    document.getElementById('ghaf-24.09').classList.remove('selected');
});

document.querySelectorAll('.menu a').forEach(link => {
    link.addEventListener('click', function() {
        document.querySelectorAll('.menu a').forEach(link => link.classList.remove('selected'));
        this.classList.add('selected');
        history.pushState({}, '', window.location.pathname + `?selected=${this.id}`);
    });
});
</script>