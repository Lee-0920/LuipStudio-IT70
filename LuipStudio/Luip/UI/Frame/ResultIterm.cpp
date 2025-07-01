#include <QLabel>
#include <QGroupBox>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QDebug>
#include "ResultIterm.h"
#include <QTextCharFormat>
#include <QGraphicsDropShadowEffect>

#define RESULT_WIDTH        360
#define RESULT_MAX_SIZE   75

//边界调试，显示主界面黑框中的三个框分别在什么位置
#define BORDER_DEBUG        0

namespace UI
{

ResultIterm::ResultIterm(QString strTarget, QString strResult,
                         QString strDateTime, QString strUnit, QWidget *parent)
    : QWidget(parent)
{
    m_targetLabel  = new QLabel();
#if BORDER_DEBUG
    m_targetLabel->setStyleSheet("QLabel{"
                                "background-color:white;"
                                "}");
#else
    m_targetLabel->setObjectName(QStringLiteral("measureLabel"));
#endif
    m_targetLabel->setFixedSize(110, 35);
    QFont measureParamFont = m_targetLabel->font();
    measureParamFont.setPointSize(15);
    measureParamFont.setWeight(QFont::DemiBold);
    m_targetLabel->setFont(measureParamFont);
    m_targetLabel->setAlignment(Qt::AlignVCenter | Qt::AlignRight );
    m_targetLabel->setText(strTarget);

    m_resultLabel = new QLabel();
#if BORDER_DEBUG
    m_resultLabel->setStyleSheet("QLabel{"
                                 "background-color:red;"
                                 "}");
#else
    m_resultLabel->setObjectName(QStringLiteral("measureLabel"));
#endif
    m_resultLabel->setFixedSize(RESULT_WIDTH, 90);
    QFont measureResultFont = m_resultLabel->font();
    measureResultFont.setWeight(75);
    measureResultFont.setPointSize(RESULT_MAX_SIZE);
    m_resultLabel->setFont(measureResultFont);
    m_resultLabel->setAlignment(Qt::AlignVCenter | Qt::AlignHCenter);
    m_resultLabel->setMargin(0);
    m_resultLabel->setText(strResult);

    m_unitLabel = new QLabel();
#if BORDER_DEBUG
    m_unitLabel->setStyleSheet("QLabel{"
                                 "background-color:white;"
                                 "}");
#else
    m_unitLabel->setObjectName(QStringLiteral("measureLabel"));
#endif
    m_unitLabel->setFixedSize(110, 35);
    QFont uintFont = m_unitLabel->font();
    uintFont.setPointSize(15);
    uintFont.setWeight(QFont::DemiBold);
    m_unitLabel->setFont(uintFont);
    m_unitLabel->setAlignment(Qt::AlignVCenter | Qt::AlignRight);
    m_unitLabel->setText(strUnit);

    QString strDate = "";
    QString strTime = "";

    DateTimeStringAnalysis(strDateTime, strDate, strTime);

    m_dateLabel = new QLabel();
#if BORDER_DEBUG
    m_dateLabel->setStyleSheet("QLabel{"
                                 "background-color:white;"
                                 "}");
#else
    m_dateLabel->setObjectName(QStringLiteral("measureLabel"));
#endif
    m_dateLabel->setFixedSize(110,35);
    QFont dateFont = m_dateLabel->font();
    dateFont.setPointSize(15);
    dateFont.setWeight(QFont::DemiBold);
    m_dateLabel->setFont(dateFont);
    m_dateLabel->setAlignment(Qt::AlignVCenter | Qt::AlignRight);
    m_dateLabel->setText(strDate);

    m_timeLabel = new QLabel();
#if BORDER_DEBUG
    m_timeLabel->setStyleSheet("QLabel{"
                                 "background-color:white;"
                                 "}");
#else
    m_timeLabel->setObjectName(QStringLiteral("measureLabel"));
#endif
    m_timeLabel->setFixedSize(110,30);
    m_timeLabel->setFont(dateFont);
    m_timeLabel->setAlignment(Qt::AlignVCenter | Qt::AlignRight);
    m_timeLabel->setText(strTime);

    QVBoxLayout *targetLayout = new QVBoxLayout();
    targetLayout->addStretch();
    targetLayout->addSpacing(7);
    targetLayout->addWidget(m_targetLabel);
    targetLayout->addWidget(m_unitLabel);
    targetLayout->addStretch();
    targetLayout->setContentsMargins(0, 0, 0, 0);

    QVBoxLayout *resultLayout = new QVBoxLayout();
    resultLayout->addStretch();
    resultLayout->addWidget(m_resultLabel);
    targetLayout->addStretch();
    resultLayout->setContentsMargins(0, 0, 0, 0);

    QVBoxLayout *dateTimeLayout = new QVBoxLayout();
    dateTimeLayout->addStretch();
    dateTimeLayout->addSpacing(7);
    dateTimeLayout->addWidget(m_dateLabel);
    dateTimeLayout->addWidget(m_timeLabel);
    dateTimeLayout->addStretch();
    dateTimeLayout->setContentsMargins(0, 0, 0, 0);

    QHBoxLayout *itermLayout = new QHBoxLayout();
    itermLayout->addLayout(dateTimeLayout);
    itermLayout->addStretch();
    itermLayout->addLayout(resultLayout);
    itermLayout->addStretch();
    itermLayout->addLayout(targetLayout);
//    itermLayout->setContentsMargins(0, 0, 0, 0);
    itermLayout->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);

    this->setLayout(itermLayout);
}

ResultIterm::~ResultIterm()
{

}
void ResultIterm::SetMeasureTarget(QString strTarget)
{
    m_targetLabel->setText(strTarget);
}

void ResultIterm::SetMeasureResult(QString strResult)
{
//    QFont typeTestFont = m_resultLabel->font();
//    int point = GetPointSize(strResult, RESULT_WIDTH-40);
//    typeTestFont.setPointSize(point);
//    typeTestFont.setWeight(80);

//    m_resultLabel->setFont(typeTestFont);
    m_resultLabel->setText(strResult);
}

void ResultIterm::SetMeasureTime(QString strDateTime)
{
    QString strDate = "";
    QString strTime = "";

    DateTimeStringAnalysis(strDateTime, strDate, strTime);
    m_dateLabel->setText(strDate);
    m_timeLabel->setText(strTime);
}

void ResultIterm::DateTimeStringAnalysis(QString &dateTime, QString &date, QString &time)
{
    QStringList strList = dateTime.split(QRegExp("[ ]"));

    if (strList.size() == 2)
    {
        date = strList.at(0);
        time = strList.at(1);
    }
}


int ResultIterm::GetPointSize(QString& text, int limitWidth)
{
    QFont font = m_resultLabel->font();
    font.setPointSize(RESULT_MAX_SIZE);
    int size = RESULT_MAX_SIZE;

    QFontMetrics fontWidth(font);
    int textWidth = fontWidth.width(text);

    while(size > 20 && textWidth > limitWidth)
    {
        size = size - 1;
        font.setPointSize(size);

        QFontMetrics fontWidth(font);
        textWidth = fontWidth.width(text);
    }

    if (size > RESULT_MAX_SIZE)
    {
        size = RESULT_MAX_SIZE;
    }
    return size;
}

void ResultIterm::SetMeasureResultFont(int fontSize)
{
    QFont measureResultFont = m_resultLabel->font();
    measureResultFont.setPointSize(fontSize);
    m_resultLabel->setFont(measureResultFont);
}

}
