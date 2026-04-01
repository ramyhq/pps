class Hijri {
    constructor(isReport = false) {
        window.moment.locale('en-GB');
        //var inputs = $('.date-picker:not(".dateFilter")');
        //inputs.each(function (i, ele) {
        //    let x = new HijriControl(ele);
        //});
        
        var views = $('.hijriView');
        views.each(function (i, ele) {
            let x = new HijriView(ele, isReport);
        });

        var viewsReport = $('.hijriViewReport');
        viewsReport.each(function (i, ele) {
            let x = new HijriView(ele, true);
        });
    }
}

class HijriControl {
    constructor(element) {
        this.gregorianElement = element;
        this.gregorianParent = $(this.gregorianElement).parent();
        this.createNewDiv();
        this.CreateAndPlaceHijriElement();
        this.MakeElementHijriPicker();
        this.AddEventListener();
        let date = this.GetGregorianMomentDate();
        this.SetHijriDate(date);
    }

    gregorianOnChange() {
        let date = this.GetGregorianMomentDate();
        if (date) {
            this.SetHijriDate(date);
        }
    }

    hijriOnChange(args) {
        if (args.date) {
            $(this.gregorianElement).val(window.moment(args.date).format('DD/MM/YYYY'));
        };
    }

    createNewDiv() {
        this.div = document.createElement('div');
        this.div.style.display = 'flex';
        this.gregorianParent.append(this.div);
        $(this.gregorianElement).appendTo(this.div);
    }

    CreateAndPlaceHijriElement() {
        this.hijriElement = document.createElement('input');
        this.hijriElement.classList.add('form-control');
        this.div.append(this.hijriElement);
    }

    MakeElementHijriPicker() {
        $(this.hijriElement).hijriDatePicker({
            hijri: true,
            locale: 'en-GB',
            hijriFormat: 'iDD/iMM/iYYYY'
        });
    }

    AddEventListener() {
        $(this.gregorianElement).on("dp.change", () => { this.gregorianOnChange() });
        $(this.hijriElement).on("dp.change", (args) => { this.hijriOnChange(args) });
    }

    GetGregorianMomentDate() {
        var currentDate = $(this.gregorianElement).data("daterangepicker").date();
        if (currentDate) {
            return currentDate.toLocaleString('en-GB');
        }
        return;
    }

    SetHijriDate(date) {
        $(this.hijriElement).val(window.moment(date).format('iDD/iMM/iYYYY'));
    }
}

class HijriView {
    constructor(element, isReport) {
        
        var t = $(element).text().trim();
        var parts = t.split('/');
        var date = new Date(parseInt(parts[2]), parseInt(parseInt(parts[1]) - 1), parseInt(parts[0]));
        var text = $(element).text();
      
        /*  text = text + " - " + window.moment(date).format('iYYYY/iM/iD');*/
        text = window.moment(date).format('iD-iM-iYYYY');

        if (isReport) {
            var textParts = text.split('-');
            text = [textParts[0], textParts[1], textParts[2].substring(2, 4)].join('-');
        }
        $(element).text(text);
    }
}

$(document).ready(function () {
    var h = new Hijri();
});